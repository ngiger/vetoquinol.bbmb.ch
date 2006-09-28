#!/usr/bin/env ruby
# Selenium::TestLogin -- bbmb.ch -- 21.09.2006 -- hwyss@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))

require "selenium/unit"

module BBMB
  module Selenium
class TestLogin < Test::Unit::TestCase
  include Selenium::TestCase
  def test_open
    @selenium.open "/"
    assert_equal "BBMB", @selenium.get_title
    assert @selenium.is_text_present("Wilkommen bei V")
    assert_equal "Email", @selenium.get_text("//label[@for='email']")
    assert @selenium.is_element_present("email")
    assert_equal "Passwort", @selenium.get_text("//label[@for='pass']")
    assert @selenium.is_element_present("pass")
    assert_match Regexp.new(BBMB.config.http_server), 
      @selenium.get_attribute("//form[@name='login']@action")
    assert @selenium.is_element_present("//input[@name='login']")
  end
end
  end
end
