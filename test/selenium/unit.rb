#!/usr/bin/env ruby
# Selenium::TestCase -- bbmb.ch -- 22.09.2006 -- hwyss@ywesee.com

require "bbmb"
require "bbmb/config"
require "bbmb/util/server"
require 'flexmock'
require 'logger'
require "selenium"
require 'stub/http_server'
require 'stub/persistence'
require "test/unit"

module BBMB
  module Selenium
module TestCase
  include FlexMock::TestCase
  def setup
    BBMB.logger = Logger.new($stdout)
    BBMB.logger.level = Logger::DEBUG
    @auth = flexmock('authenticator')
    BBMB.auth = @auth
    @persistence = flexmock('persistence')
    BBMB.persistence = @persistence
    @server = Util::Server.new(@persistence)
    @server.extend(DRbUndumped)
    drb_url = "druby://localhost:10081"
    @drb = Thread.new { 
      begin
        @drb_server = DRb.start_service(drb_url, @server) 
      rescue Exception => e
        puts e.class
        puts e.message
        puts e.backtrace
        current.raise(e)
        raise
      end
    }
    @drb.abort_on_exception = true
    @http_server = Stub.http_server(drb_url)
    @webrick = Thread.new { @http_server.start }
    @verification_errors = []
    if $selenium
      @selenium = $selenium
    else
      @selenium = ::Selenium::SeleneseInterpreter.new("localhost", 4444, 
        "*firefox", BBMB.config.http_server + ":10080", 10000);
      @selenium.start
    end
    @selenium.set_context("TestCustomers", "info")
  end
  def teardown
    #@selenium.stop unless $selenium
    @http_server.shutdown
    @drb_server.stop_service
    assert_equal [], @verification_errors
  end
  def login(email, *permissions)
    user = mock_user email, *permissions
    @auth.should_receive(:login).and_return(user)
    @auth.should_ignore_missing
    @selenium.open "/"
    @selenium.type "email", email
    @selenium.type "pass", "test"
    @selenium.click "//input[@name='login']"
    @selenium.wait_for_page_to_load "30000"
    user
  end
  def login_admin
    login "test.admin@bbmb.ch", ['login', 'ch.bbmb.Admin'], 
          ['edit', 'yus.entities']
  end
  def login_customer
    email = "test.customer@bbmb.ch"
    @customer = Model::Customer.new('007')
    @customer.instance_variable_set('@email', email)
    login email, ['login', 'ch.bbmb.Customer']
  end
  def mock_user(email, *permissions)
    user = flexmock(email)
    user.should_receive(:allowed?).and_return { |*pair|
      permissions.include?(pair)
    }
    user.should_receive(:name).and_return(email)
    user.should_ignore_missing
    user
  end
end
  end
end
