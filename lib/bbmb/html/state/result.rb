#!/usr/bin/env ruby
# Html::State::Result -- bbmb.ch -- 21.09.2006 -- hwyss@ywesee.com

require 'bbmb/html/state/global'
require 'bbmb/html/view/result'

module BBMB
  module Html
    module State
class Result < Global
  class Result 
    include Enumerable
    attr_reader :order, :products
    def initialize(order, products)
      @order, @products = order, products
    end
    def each(&block)
      @products.each(&block)
    end
    def empty?
      @products.empty?
    end
    def ordered_quantity(article_number)
      @order.quantity(article_number)
    end
    def reverse!
      @products.reverse!
    end
    def size
      @products.size
    end
    def sort_by(&block)
      @products = @products.sort_by(&block)
      self
    end
    def sort!(*args, &block)
      @products.sort!(*args, &block)
    end
  end
  VIEW = View::Result
  def init
    products = Model::Product.search_by_description(@session.user_input(:query))
    @model = Result.new(_customer.current_order, products)
  end
  def direct_event
    [:search, {:query => @session.persistent_user_input(:query)}]
  end
end
    end
  end
end
