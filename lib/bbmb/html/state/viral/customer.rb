#!/usr/bin/env ruby
# Html::State::Viral::Customer -- bbmb.ch -- 20.09.2006 -- hwyss@ywesee.com

require 'bbmb/html/state/current_order'
require 'bbmb/html/state/favorites'
require 'bbmb/html/state/favorites_result'
require 'bbmb/html/state/order'
require 'bbmb/html/state/orders'
require 'bbmb/html/state/result'
require 'sbsm/viralstate'

module BBMB
  module Html
    module State
      module Viral
module Customer
  include SBSM::ViralState
  EVENT_MAP = {
    :current_order    =>  State::CurrentOrder,
    :favorites        =>  State::Favorites,
    :orders           =>  State::Orders,
    :search           =>  State::Result,
    :search_favorites =>  State::FavoritesResult,
  }
  def _customer
    @customer ||= Model::Customer.find_by_email(@session.user.name)
  end
  def _increment_order(order)
    quantities = @session.user_input(:quantity)
    if(error?)
      false
    else
      quantities.each { |article_number, quantity|
        order.increment(quantity.to_i, 
                        Model::Product.find_by_article_number(article_number))
      }
      BBMB.persistence.save(order, _customer)
      true
    end
  end
  def _update_order(order)
    quantities = @session.user_input(:quantity)
    if(error?)
      false
    else
      quantities.each { |article_number, quantity|
        order.add(quantity.to_i, 
                  Model::Product.find_by_article_number(article_number))
      }
      BBMB.persistence.save(order, _customer)
      true
    end
  end
  def clear_favorites
    _customer.favorites.clear
    self
  end
  def clear_order
    _customer.current_order.clear
    self
  end
  def favorite_product
    if(_update_order(_customer.favorites))
      trigger(:favorites)
    end
  end
  def home
    trigger(@session.user.home || :current_order)
  end
  def increment_order
    if(_increment_order(_customer.current_order))
      trigger(:current_order)
    end
  end
  def order
    if(order_id = @session.user_input(:order_id))
      customer_id, commit_id = order_id.split('-', 2)
      State::Order.new(@session, _customer.order(commit_id))
    end
  end
  def order_product
    if(_update_order(_customer.current_order))
      trigger(:current_order)
    end
  end
  def zone_navigation
    [ :current_order, :orders, :favorites ]
  end
end
      end
    end
  end
end
