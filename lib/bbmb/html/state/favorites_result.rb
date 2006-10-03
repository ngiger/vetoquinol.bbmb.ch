#!/usr/bin/env ruby
# Html::State::Result -- bbmb.ch -- 21.09.2006 -- hwyss@ywesee.com

require 'bbmb/html/state/result'
require 'bbmb/html/view/favorites_result'

module BBMB
  module Html
    module State
class FavoritesResult < Result
  VIEW = View::FavoritesResult
  def init
    products = Model::Product.search_by_description(@session.user_input(:query))
    @model = Result::Result.new _customer.favorites, products.select { |product|
			product.price
		}
  end
  def direct_event
    [:search_favorites, {:query => @session.persistent_user_input(:query)}]
  end
end
    end
  end
end
