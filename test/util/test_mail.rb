#!/usr/bin/env ruby
# Util::TestMail -- bbmb.ch -- 27.09.2006 -- hwyss@ywesee.com


$: << File.expand_path('../lib', File.dirname(__FILE__))

require 'bbmb/util/mail'
require 'flexmock'
require 'test/unit'

module BBMB
  module Util
    class TestMail < Test::Unit::TestCase
      include FlexMock::TestCase
      def test_send_order
        order = flexmock('order')
        order.should_receive(:to_i2).and_return('test')
        config = flexmock('config')
        BBMB.config = config
        config.should_receive(:mail_order_from).and_return('from.test@bbmb.ch')
        config.should_receive(:mail_order_to).and_return('to.test@bbmb.ch')
        config.should_receive(:mail_order_cc).and_return('cc.test@bbmb.ch')
        config.should_receive(:smtp_server).and_return('mail.test.com')
        smtp = flexmock('smtp')
        flexstub(Net::SMTP).should_receive(:start).and_return { |srv, block|
          assert_equal('mail.test.com', srv)
          block.call(smtp) 
        }
        expected = <<-EOS
From: from.test@bbmb.ch
To: to.test@bbmb.ch
Cc: cc.test@bbmb.ch

test
        EOS
        smtp.should_receive(:sendmail).and_return { |message, from, recipients|
          assert_equal(expected, message)
          assert_equal('from.test@bbmb.ch', from)
          assert_equal(['to.test@bbmb.ch', 'cc.test@bbmb.ch'], recipients)
        }
        Mail.send_order(order)
      end
    end
  end
end
