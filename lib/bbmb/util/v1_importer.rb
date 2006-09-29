#!/usr/bin/env ruby
# Util::V1Importer -- bbmb.ch -- 28.09.2006 -- hwyss@ywesee.com

require 'iconv'
require 'parseexcel/parseexcel'

module BBMB
  module Util
class V1Importer
  include DRb::DRbUndumped
  def V1Importer.run(drb_uri, options={})
    imp = self.new
    imp.load_translations(options)
    imp.import(drb_uri)
  end
  def initialize
    @flavor = 'vetoquinol'
    @group_short = Iconv.new('latin1', 'utf-8').iconv('Vétoqu')
    @gag_vtq = {}
    @vtq_new = {}
    @products = {}
    @iconv = Iconv::Iconv.new('utf-8', 'latin1')
  end
  def cell(row, idx, encoding)
    if(cell = row.at(idx))
      cell.to_s('latin1').strip
    end
  end
  def create_user(copy, email, pass)
    BBMB.auth.autosession(BBMB.config.auth_domain) { |session|
      session.create_entity(email, pass) rescue Yus::YusError
      session.grant(email, 'login', BBMB.config.auth_domain + '.Customer')
      ## use instance_variable_set, because email= tries to create a user
      #  and autosession does not allow set_password
      copy.instance_variable_set('@email', email)
      copy.protect!(:email)
    }
  end
  def data(item, key)
    value = item.value(key)
    if(value.is_a?(String))
      string(value)
    else
      value
    end
  end
  def import(drb_uri)
    v1 = DRb::DRbObject.new(nil, drb_uri)
    v1.admin("require 'util/drbwrapper'")
    DRb.start_service
    v1.each_hospital { |user|
      short = user.value(:group_short)
      BBMB.logger.debug('v1importer') { 
        sprintf "comparing %s with group_short %s", @group_short, short.inspect }
      if(short == @group_short)
        import_customer(user)
      end
      nil
    }
  end
  def import_archive(user, customer)
    BBMB.logger.debug('v1importer') { "importing archived orders" }
    user.orders(@flavor).values.sort_by { |order| 
      order.commit_time 
    }.each { |order|
      copy = customer.current_order 
      import_order(order, copy) { |position|
        import_archive_position(position)
      }
      customer.commit_order!(order.commit_time)
    }
    BBMB.logger.debug('v1importer') { 
      "imported %i archived orders" % customer.archive.size }
  end
  def import_archive_position(position)
    anum = data(position, :article_number)
    id = @products[anum]
    BBMB.logger.debug('v1importer') { 
      sprintf "importing archive-position %s -> %s", anum, id }
    product = Model::Product.new(id || anum)
    { :article_status => :status, 
      :article_ean13  => :ean13,
      :article_descr  => :description,
      :article_price  => :price,
      :article_mwst   => :mwst,
      :article_pcode  => :pcode, 
      :article_l3_q1  => :l1_qty,
      :article_l3_p1  => :l1_price,
      :article_l3_q2  => :l2_qty,
      :article_l3_p2  => :l2_price,
      :article_l3_q3  => :l3_qty,
      :article_l3_p3  => :l3_price,
      :article_l3_q4  => :l4_qty,
      :article_l3_p4  => :l4_price,
      :article_l3_q5  => :l5_qty,
      :article_l3_p5  => :l5_price,
      :article_l3_q6  => :l6_qty,
      :article_l3_p6  => :l6_price,
      :article_index  => :partner_index,
    }.each { |key1, key2|
      product.send("#{key2}=", data(position, key1))
    }
    product
  end
  def import_current_order(user, customer)
    BBMB.logger.debug('v1importer') { "importing current order " }
    order = customer.current_order
    import_order(user.current_order(@flavor), order) { |position|
      import_position(position)
    }
  end
  def import_customer(user)
    cid = data(user, :customer_id)
    email = string(user.email)
    BBMB.logger.debug('v1importer') { "translating customer_id %s" % cid }
    if(id = @vtq_new[@gag_vtq[cid]])
      BBMB.logger.debug('v1importer') { 
        sprintf "importing customer %s -> %s", cid, id }
      copy = Model::Customer.find_by_customer_id(id) || Model::Customer.new(id)
      [ :address1, :address2, :address3, :drtitle, :fax, :firstname,
        :lastname, :phone_business, :phone_mobile, :phone_private, :plz, 
      ].each { |key|
        if(value = data(user, key))
          copy.send("#{key}=", value)
          copy.protect!(key)
        end
      }
      { :gender         => :title, 
        :kanton         => :canton, 
        :location       => :city,
        :customer_ean13 => :ean13,
      }.each { |key1, key2|
        if(value = data(user, key1))
          copy.send("#{key2}=", value)
          copy.protect!(key2)
        end
      }
      if(email)
        BBMB.logger.debug('v1importer') { "user has email %s" % email }
        if(pass = data(user, :pass_hash))
          create_user(copy, email, pass)
        end
        import_archive(user, copy)
        import_favorites(user, copy)
        import_current_order(user, copy)
      end
      BBMB.persistence.save(copy)
    else
      gid = @gag_vtq[cid]
      BBMB.logger.warn('v1importer') {
        sprintf "unknown customer %s(%s) - %s(%s) - %s(%s)",
                cid, cid.class, gid, gid.class, id, id.class
      }
    end
  rescue Exception => e
    BBMB.logger.error('v1importer') { 
      ([ e.class.to_s, e.message ].concat e.backtrace).pretty_inspect
    }
    raise
  end
  def import_favorites(user, customer)
    BBMB.logger.debug('v1importer') { "importing favorites " }
    import_order(user.favorites(@flavor), customer.favorites) { |position|
      import_position(position)
    }
  end
  def import_info(position)
    info = Model::Order::Info.new
    info.quantity = position.size
    info.description = data(position, :article_descr)
    info.ean13 = data(position, :article_ean13)
    info.pcode = data(position, :article_pcode)
    info
  end
  def import_order(original, order, &block)
    BBMB.logger.debug('v1importer') { 
      "importing order with %i positions" % original.size }
    original.each_value { |position|
      if(product = block.call(position))
        order.add(position.size, product)
      else
        order.unavailable.push(import_info(position))
      end
    }
    BBMB.persistence.save(order)
  end
  def import_position(position)
    anum = data(position, :article_number)
    BBMB.logger.debug('v1importer') { "importing position %s" % anum }
    if((id = @products[anum]) \
        && (product = Model::Product.find_by_article_number(id)))
      product
    else
      BBMB.logger.warn('v1importer') { 
        sprintf "impossible import - unknown product %s - %s - %s", 
                position.value(:article_number), 
                data(position, :article_number), id
      }
      nil
    end
  end
  def load_translations(options)
    options.each { |key, path|
      self.send("load_#{key}", Spreadsheet::ParseExcel.parse(path))
    }
  end
  def load_gag_vtq(book)
    book.worksheet(0).each(1) { |row|
      @gag_vtq.store(sprintf("%i", row.at(0).to_i), 
                     sprintf("C%08i", row.at(1).to_i))
    }
    BBMB.logger.debug('v1importer') { 
      "loaded %i gag-vtq-mappings" % @gag_vtq.size }
  end
  def load_vtq_new(book)
    book.worksheet(0).each(1) { |row|
      @vtq_new.store(cell(row, 3, 'latin1'), u(cell(row, 1, 'utf-8')))
    }
    BBMB.logger.debug('v1importer') { 
      "loaded %i vtq-new-mappings" % @vtq_new.size }
  end
  def load_products(book)
    book.worksheet(0).each(1) { |row|
      gag = cell(row, 2, 'latin1').to_i
      if(gag > 0)
        @products.store(gag.to_s, u(cell(row, 5, 'utf-8')))
      end
    }
    BBMB.logger.debug('v1importer') { 
      "loaded %i product-mappings" % @products.size }
  end
  def string(value)
    str = u(@iconv.iconv(value.to_s)).strip
    str unless(str.empty?)
  end
end
  end
end
