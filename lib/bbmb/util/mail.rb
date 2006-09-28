#!/usr/bin/env ruby
# Util::Mail -- bbmb.ch -- 27.09.2006 -- hwyss@ywesee.com

require 'bbmb/config'
require 'net/smtp'
require 'rmail'

module BBMB
  module Util
module Mail
  def Mail.send_order(order)
    message = RMail::Message.new
    attachment = RMail::Message.new
    attachment.body = order.to_i2
    header = attachment.header
    header.add('Content-Type', 'text/plain', nil, 'charset' => 'utf-8')
    header.add('Content-Disposition', 'attachment', nil, 
               'filename' => order.filename)
    message.add_part(attachment)
    config = BBMB.config
    header = message.header
    from = header.from = config.mail_order_from
    to = header.to = config.mail_order_to
    cc = header.cc = config.mail_order_cc
    header.subject = config.mail_order_subject % order.order_id
    Net::SMTP.start(config.smtp_server, config.smtp_port, config.smtp_helo,
                    config.smtp_user, config.smtp_pass, 
                    config.smtp_authtype) { |smtp|
      smtp.sendmail(message.to_s, from, [to, cc].flatten)
    }
  end
end
  end
end
