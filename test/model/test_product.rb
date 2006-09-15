#!/usr/bin/env ruby
# Model::TestProduct -- bbmb.ch -- 14.09.2006 -- hwyss@ywesee.com

$: << File.expand_path('../../lib', File.dirname(__FILE__))

require 'test/unit'
require 'bbmb/model/product'

module BBMB
  module Model
    class TestProduct < Test::Unit::TestCase
      def setup
        @product = Product.new("article_number")
      end
      def test_int_accessors
        [:l1_qty, :l2_qty, :l3_qty, :l4_qty, :l5_qty, :l6_qty, 
          :mwst ].each { |key|
          assert_nil(@product.send(key))
          @product.send("#{key}=", "2")
          int = @product.send(key)
          assert_instance_of(Fixnum, int)
          assert_equal(2, int)
          @product.send("#{key}=", nil)
          assert_nil(@product.send(key))
        }
      end
      def test_money_accessors
        [:price, :l1_price, :l2_price, :l3_price, :l4_price, :l5_price,
          :l6_price ].each { |key|
          assert_nil(@product.send(key))
          @product.send("#{key}=", "1.23")
          price = @product.send(key)
          assert_instance_of(Util::Money, price)
          assert_equal(1.23, price)
          @product.send("#{key}=", nil)
          assert_nil(@product.send(key))
        }
      end
      def test_backorder_accessor
        assert_equal(false, @product.backorder)
        @product.backorder = "yes"
        assert_equal(true, @product.backorder)
        @product.backorder = "no"
        assert_equal(false, @product.backorder)
        @product.backorder = 1
        assert_equal(true, @product.backorder)
        @product.backorder = "1"
        assert_equal(true, @product.backorder)
        @product.backorder = nil
        assert_equal(false, @product.backorder)
      end
    end
  end
end
