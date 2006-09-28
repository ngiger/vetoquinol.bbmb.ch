#!/usr/bin/env ruby
# Html::State::Global -- bbmb.ch -- 18.09.2006 -- hwyss@ywesee.com

require 'sbsm/state'
require 'bbmb/html/state/login'
require 'encoding/character/utf-8'

module BBMB
  module Html
    module State
class Global < SBSM::State
  class << self
    def mandatory(*keys)
      define_method(:mandatory) { keys }
      define_method(:mandatory?) { |key| keys.include?(key) }
    end
  end
  def logout
    @session.logout
    State::Login.new(@session, nil)
  end
  def trigger(event)
    if(event == direct_event)
      self
    else
      super
    end
  end
  def user_input(*args)
    data = super
    data.each { |key, val|
      if(val.is_a?(String))
        data.store(key, val.empty? ? nil : u(val))
      end
    }
    data
  end
end
    end
  end
end
