#!/usr/bin/env ruby
# Model::Product -- bbmb.ch -- 14.09.2006 -- hwyss@ywesee.com

require 'bbmb/util/money'

module BBMB
  module Model
    class Product
      def Product.int_accessor(*keys)
        keys.each { |key|
          attr_reader key
          define_method("#{key}=") { |value|
            int = value.to_i if(value)
            instance_variable_set("@#{key}", int)
          }
        }
      end
      def Product.money_accessor(*keys)
        keys.each { |key|
          attr_reader key
          define_method("#{key}=") { |value|
            money = Util::Money.new(value) if(value)
            instance_variable_set("@#{key}", money)
          }
        }
      end
      attr_reader :article_number, :backorder
      attr_accessor :description, :ean13, :partner_index, :pcode, :status
      int_accessor :l1_qty, :l2_qty, :l3_qty, :l4_qty, :l5_qty, :l6_qty, :mwst
      money_accessor :price, :l1_price, :l2_price, :l3_price, :l4_price, 
        :l5_price, :l6_price
      def initialize(article_number)
        @article_number = article_number
        @backorder = false
      end
      def backorder=(value)
        case value
        when true, 1, /^(ja|yes|1)$/i
          @backorder = true
        else
          @backorder = false
        end
      end
    end
  end
end
