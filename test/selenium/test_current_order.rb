#!/usr/bin/env ruby
# Selenium::TestCurrentOrder -- bbmb.ch -- 22.09.2006 -- hwyss@ywesee.com


$: << File.expand_path('../lib', File.dirname(__FILE__))

require 'selenium/unit'

module BBMB
  module Selenium
class TestCurrentOrder < Test::Unit::TestCase
  include Selenium::TestCase
  def perform_login
    user = flexmock('auth_user')
    user.should_receive(:allowed?).and_return { |*pair|
      case pair
      when ['login', 'ch.bbmb.Customer']
        true
      end
    }
    user.should_receive(:name).and_return('test.admin@bbmb.ch')
    user.should_ignore_missing
    @auth.should_receive(:login).and_return(user)
    @auth.should_ignore_missing
    @selenium.open "/"
    @selenium.type "email", "test.customer@bbmb.ch"
    @selenium.type "pass", "test"
    @selenium.click "//input[@name='login']"
    @selenium.wait_for_page_to_load "30000"
    user
  end
  def test_current_order
    user = perform_login 
    assert @selenium.is_text_present("1 bis 1 von 1")
    assert_equal "BBMB", @selenium.get_title
    assert @selenium.is_text_present("Kundennr")
    assert @selenium.is_text_present("007")
    assert @selenium.is_text_present("PLZ")
    assert @selenium.is_text_present("7777")
    assert @selenium.is_text_present("Aktiviert")
  end
end
  end
end
