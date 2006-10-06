#!/usr/bin/env ruby
# Selenium::TestLogin -- bbmb.ch -- 21.09.2006 -- hwyss@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))

require "selenium/unit"

module BBMB
  module Selenium
class TestLogin < Test::Unit::TestCase
  include Selenium::TestCase
  def test_login
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
  def test_login__fail_unknown_user
    @selenium.open "/"
    assert_equal "BBMB", @selenium.get_title
    @auth.should_receive(:login).and_return { raise Yus::UnknownEntityError }
    @selenium.type "email", "unknown@bbmb.ch"
    @selenium.type "pass", "secret"
    @selenium.click "//input[@type='submit']"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "BBMB", @selenium.get_title
    assert_equal "error", @selenium.get_attribute("//label[@for='email']@class")
  end
  def test_login__fail_wrong_password
    @selenium.open "/"
    assert_equal "BBMB", @selenium.get_title
    @auth.should_receive(:login).and_return { raise Yus::AuthenticationError }
    @selenium.type "email", "unknown@bbmb.ch"
    @selenium.type "pass", "secret"
    @selenium.click "//input[@type='submit']"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "BBMB", @selenium.get_title
    assert_equal "error", @selenium.get_attribute("//label[@for='pass']@class")
  end
  def test_login__force_home
    @selenium.open "/"
    assert_equal "BBMB", @selenium.get_title
    @selenium.open "/de/home"
    assert @selenium.is_text_present("Wilkommen bei V")
    assert @selenium.is_element_present("email")
    assert @selenium.is_element_present("pass")
    assert @selenium.is_element_present("//input[@name='login']")
  end
  def test_logout__clean
    @auth.should_ignore_missing
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
  def test_logout__timeout
    @auth.should_ignore_missing
    @persistence.should_receive(:all).and_return([])
    user = login_admin
    user.should_receive(:expired?).and_return(true)
    user.should_receive(:logout)
    @selenium.refresh
    @selenium.wait_for_page_to_load "30000"
    assert_equal "BBMB", @selenium.get_title
    assert @selenium.is_element_present("email")
    assert @selenium.is_element_present("pass")
  end
  def test_logout__disconnect
    @auth.should_ignore_missing
    @persistence.should_receive(:all).and_return([])
    user = login_admin
    user.should_receive(:expired?).and_return { raise DRb::DRbError }
    @selenium.refresh
    @selenium.wait_for_page_to_load "30000"
    assert_equal "BBMB", @selenium.get_title
    assert @selenium.is_element_present("email")
    assert @selenium.is_element_present("pass")
  end
end
  end
end
