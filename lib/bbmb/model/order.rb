#!/usr/bin/env ruby
# Model::Order -- bbmb.ch -- 22.09.2006 -- hwyss@ywesee.com

require 'encoding/character/utf-8'
require 'bbmb/util/numbers'

module BBMB
  module Model
class Order
  class Info
    include Util::Numbers
    attr_accessor :ean13, :pcode, :description
    int_accessor :quantity
  end
  class Position
    include Util::Numbers
    attr_reader :product
    int_accessor :quantity
    def initialize(quantity, product)
      @quantity = quantity
      @product = product
    end
    def commit!
      @product = @product.dup
    end
    def method_missing(name, *args, &block)
      @product.send(name, *args, &block)
    end
    def total
      @product.price(@quantity) * @quantity
    end
    def respond_to?(name)
      super || @product.respond_to?(name)
    end
  end
  include Enumerable
  include Util::Numbers
  attr_reader :commit_id, :commit_time, :positions, :unavailable
  attr_accessor :comment, :reference
  int_accessor :priority
  money_accessor :shipping
  def initialize(customer)
    @customer = customer
    @positions = []
    @unavailable = []
  end
  def add(quantity, product)
    if(pos = position(product))
      if(quantity.zero?)
        @positions.delete(pos)
      else
        pos.quantity = quantity
        pos
      end
    elsif(quantity.nonzero?)
      @positions.push(Position.new(quantity, product)).last
    end
  end
  def additional_info
    info = {}
    [ :comment, :priority, :reference ].each { |key|
      if(value = self.send(key))
        info.store(key, value)
      end
    }
    info
  end
  def clear
    @positions.clear
  end
  def commit!(commit_id, commit_time)
    raise "can't commit empty order" if(empty?)
    @positions.each { |pos| pos.commit! }
    @unavailable.clear
    @commit_time = commit_time
    @commit_id = commit_id
  end
  def each(&block)
    @positions.each(&block)
  end
  def empty?
    @positions.empty?
  end
  def filename
    sprintf("%s-%s.dat", order_id, @commit_time.strftime('%Y%m%d%H%M%S'))
  end
  def increment(quantity, product)
    if(pos = position(product))
      quantity += pos.quantity
    end
    add(quantity, product)
  end
  def i2_body
    lines = []
    @positions.each_with_index { |position, idx|
      lines.push "500:%i" % idx.next,
				"501:%s" % position.ean13,
				"502:%s" % position.article_number,
				"520:%s" % position.quantity,
				"521:PCE", "540:2", "541:%s" % @commit_time.strftime('%Y%m%d')
    }
    lines.join("\n")
  end
  def i2_header
    lines = [
      "001:7601001000681",
      "002:ORDERX",
      "003:220",
      "010:%s" % filename,
      "100:YWESEE",
      "101:%s" % @reference,
      "201:CU",
      "202:%s" % @customer.customer_id,
      "201:BY",
      "202:1075",
      "231:%s" % @customer.organisation,
    ]
    if(@comment && !@comment.empty?)
      lines.push "236:%s" % u(@comment.gsub(/[\r\n]+/, ';'))[0,60]
    end
    lines.push "237:61"
    if(@priority)
      lines.push "238:%i" % @priority
    end
    lines.push "250:ADE", 
                sprintf("251:%i%05i", @customer.customer_id, @commit_id), 
                "300:4", "301:%s" % @commit_time.strftime('%Y%m%d')
    lines.join("\n")
  end
  def order_id
    sprintf "%s-%s", @customer.customer_id, @commit_id
  end
  def position(product)
    @positions.find { |pos| pos.product == product }
  end
  def quantity(product)
    if(pos = position(product))
      pos.quantity
    else
      0
    end
  end
  def size
    @positions.size
  end
  def total
    @positions.inject(@shipping) { |memo, pos| pos.total + memo }
  end
  def to_i2
    i2_header << "\n" << i2_body << "\n"
  end
end
  end
end
