#!/usr/bin/env ruby
# Util::CsvImporter -- bbmb.ch -- 14.09.2006 -- hwyss@ywesee.com

require 'bbmb'
require 'bbmb/model/customer'
require 'bbmb/model/product'
module BBMB
  module Util
    class CsvImporter
      def import(io, persistence=BBMB.persistence)
        ## amazingly, all three possible non-naive approaches to parsing
        #  CSV fail with the test-data provided by Vetoquinol. For now, use the
        #  naive approach
        #CSV.parse(io, ";") { |record|
        #FasterCSV.parse(io, :col_sep => ";", :row_sep => "\n") { |record|
        #CSVParser.parse(io, false, ';').each { |record|
        if io.is_a?(String)
          begin
            lines = io.split("\n")
          rescue
            lines = io.force_encoding('ISO-8859-1').split("\n")
          end
        else
          lines = io
        end

        count = 0
        lines.each { |line|
          record = line.split(';')
          if(object = import_record(record))
            persistence.save(object)
          end
          count += 1
        }
        postprocess(persistence)
        count
      end
      def postprocess(persistence=BBMB.persistence)
      end
      def string(str)
        return nil unless str
        begin
          encoded = str.encode('utf-8')
        rescue => error
          encoded = str.force_encoding('ISO-8859-1').encode('utf-8')
        end
        encoded.gsub(/\s+/, ' ') unless encoded.empty?
      end
    end
    class CustomerImporter < CsvImporter
      CUSTOMER_MAP = {
        4		=>	:drtitle,
        5		=>	:organisation,
        6		=>	:address1,
        7		=>	:address2,
        8		=>	:address3,
        10	=>	:plz,
        11	=>	:city,
        12	=>	:phone_business,
        13	=>	:phone_mobile,
        14	=>	:phone_private,
        15	=>	:fax,
        16	=>	:email,
      }
      def import_record(record)
        customer_id = string(record[0])
        customer = Model::Customer.find_by_customer_id(customer_id) \
          || Model::Customer.new(customer_id)
        # TODO: protect user-edited data
        CUSTOMER_MAP.each do |idx, name|
          unless customer.protects? name
            value = string(record[idx])
            if name.to_s.eql?('email')
              if value && value.strip.length > 0
                customer.set_email_without_yus(value)
                customer.odba_store
              end
            else
              customer.send("#{name}=", value ? value.strip : '')
            end
          end
        end
        customer
      end
    end
    class ProductImporter < CsvImporter
      attr_reader :active_products
      PRODUCT_MAP = {
        0		=>	:status,
        2		=>	:ean13,
        3		=>	:description,
        5		=>	:price,
        14	=>	:vat,
        27	=>	:pcode,
        28	=>	:l1_qty,   # Staffelpreise, Stück 1
        29	=>	:l1_price, # Staffelpreise, Preis 1
        30	=>	:l2_qty,   # Staffelpreise, Stück 2
        31	=>	:l2_price, # Staffelpreise, Preis 2
        32	=>	:l3_qty  , # Staffelpreise, Stück 3
        33	=>	:l3_price, # Staffelpreise, Preis 3
        34	=>	:l4_qty  , # Staffelpreise, Stück 4
        35	=>	:l4_price, # Staffelpreise, Preis 4
        36	=>	:l5_qty  , # Staffelpreise, Stück 5
        37	=>	:l5_price, # Staffelpreise, Preis 5
        38	=>	:l6_qty  , # Staffelpreise, Stück 6
        39	=>	:l6_price, # Staffelpreise, Preis 6
        40	=>	:partner_index, # Partner-Index
        41	=>	:backorder, # Rückstand-Flag
      }
      def initialize
        @active_products = {}
        super
      end
      def import_record(record)
        status = string(record[0])
        unless(status == "gesperrt")
          article_number = string(record[1])
          @active_products.store(article_number, true)
          product = Model::Product.find_by_article_number(article_number) \
            || Model::Product.new(article_number)
          PRODUCT_MAP.each do |idx, name|
            value = string(record[idx])
            next unless value
            case name
            when :description
              product.description.de = value.strip
            else
              product.send("#{name}=", value.strip)
            end
          end
          product
        end
      end
      def postprocess(persistence)
        return if(@active_products.empty?)
        deletables = []
        persistence.all(BBMB::Model::Product) { |product|
          unless(@active_products.include?(product.article_number))
            deletables.push product
          end
        }
        persistence.all(BBMB::Model::Customer) { |customer|
          [customer.current_order, customer.favorites].each { |order|
            deletables.each { |product|
              order.add(0, product)
            }
          }
        }
        persistence.delete(*deletables) unless(deletables.empty?)
      end
    end
  end
end
