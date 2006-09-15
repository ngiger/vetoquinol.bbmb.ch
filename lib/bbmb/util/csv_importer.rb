#!/usr/bin/env ruby
# Util::CsvImporter -- bbmb.ch -- 14.09.2006 -- hwyss@ywesee.com

require 'bbmb'
require 'bbmb/model/product'
require 'bbmb/model/user'
require 'csv'
require 'encoding/character/utf-8'
require 'iconv'

module BBMB
  module Util
    class CsvImporter
      def import(io, persistence=BBMB.persistence)
        CSV.parse(io, ";") { |record|
          object = import_record(record)
          persistence.save(object)
        }
      end
      def string(str)
        str = u(Iconv.new('utf-8', 'latin1').iconv(str.to_s))
        str unless str.empty? 
      end
    end
    class UserImporter < CsvImporter
      USER_MAP = {
        4		=>	:drtitle,
        5		=>	:organisation,
        6		=>	:address1,
        7		=>	:address2,
        8		=>	:address3,
        10	=>	:plz,
        11	=>	:location,
        12	=>	:phone_business,
        13	=>	:phone_mobile,
        14	=>	:phone_private,
        15	=>	:fax,
        16	=>	:email,
      }	
      def import_record(record)
        customer_id = string(record[0])
        user = Model::User.find_by_customer_id(customer_id) \
          || Model::User.new(customer_id)
        USER_MAP.each { |idx, name|
          user.send("#{name}=", string(record[idx]))
        }
        user
      end
    end
    class ProductImporter < CsvImporter
      PRODUCT_MAP = {
        0		=>	:status,
        2		=>	:ean13,
        3		=>	:description,
        5		=>	:price,
        14	=>	:mwst,
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
      def import_record(record)
        article_number = string(record[1])
        product = Model::Product.find_by_article_number(article_number) \
          || Model::Product.new(article_number)
        PRODUCT_MAP.each { |idx, name|
          product.send("#{name}=", string(record[idx]))
        }
        product
      end
    end
  end
end
