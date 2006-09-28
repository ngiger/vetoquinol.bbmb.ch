#!/usr/bin/env ruby
# Selenium::TestCustomers -- bbmb.ch -- 21.09.2006 -- hwyss@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))

require "selenium/unit"

module BBMB
  module Selenium
class TestCustomers < Test::Unit::TestCase
  include Selenium::TestCase
  def test_customers
    customer = BBMB::Model::Customer.new('007')
    customer.organisation = 'Test-Customer'
    customer.plz = '7777'
    @persistence.should_receive(:all).and_return { |klass|
      assert_equal(BBMB::Model::Customer, klass)
      [customer]
    }
    user = login_admin
    assert @selenium.is_text_present("1 bis 1 von 1")
    assert_equal "BBMB", @selenium.get_title
    assert @selenium.is_text_present("Kundennr")
    assert @selenium.is_text_present("007")
    assert @selenium.is_text_present("PLZ")
    assert @selenium.is_text_present("7777")
    assert @selenium.is_text_present("Aktiviert")
  end
  def test_clean_logout
    @persistence.should_receive(:all).and_return([])
    user = login_admin
    assert @selenium.is_element_present("link=Abmelden")
    assert_equal "Abmelden", @selenium.get_text("link=Abmelden")
    @selenium.click "link=Abmelden"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "BBMB", @selenium.get_title
    assert_equal "Email", @selenium.get_text("//label[@for='email']")
    assert @selenium.is_element_present("email")
    assert_equal "Passwort", @selenium.get_text("//label[@for='pass']")
    assert @selenium.is_element_present("pass")
    @selenium.open "/de/customers"
    # session is now invalid, we stay in login-mask
    assert_equal "BBMB", @selenium.get_title
    assert_equal "Email", @selenium.get_text("//label[@for='email']")
    assert @selenium.is_element_present("email")
    assert_equal "Passwort", @selenium.get_text("//label[@for='pass']")
    assert @selenium.is_element_present("pass")
  end
end
  end
end
