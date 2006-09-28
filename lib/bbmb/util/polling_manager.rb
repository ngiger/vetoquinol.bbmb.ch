#!/usr/bin/env ruby
# Util::PollingManager -- bbmb.ch -- 14.09.2006 -- hwyss@ywesee.com

require 'bbmb'
require 'fileutils'
require 'uri'
require 'yaml'
require 'net/pop'
require 'rmail'

module BBMB
  module Util
class PopMission 
  attr_accessor :host, :port, :user, :pass, :delete
  @@ptrn = /filename=(?:(?:(?<quote>['"])(?<file>.*?)(?<!\\)\k<quote>)|(?:(?<file>.+?)(?:;|$)))/
  def poll(&block)
    Net::POP3.start(@host, @port || 110, @user, @pass) { |pop|
      pop.each_mail { |mail|
        source = mail.pop
        ## work around a bug in RMail::Parser that cannot deal with
        ## RFC-2822-compliant CRLF..
        source.gsub!(/\r\n/, "\n")
        poll_message(RMail::Parser.read(source), &block)
        mail.delete if(@delete)
      }
    }
  end
  def poll_message(message, &block)
    if(message.multipart?)
      message.each_part { |part|
        poll_message(part, &block)
      }
    elsif(match = @@ptrn.match(message.header["Content-Disposition"]))
      block.call(match["file"], message.decode)
    end
  end
end
class PollingManager
  def load_sources(&block)
    file = File.open(BBMB.config.polling_file)
    YAML.load_documents(file) { |mission|
      block.call(mission)
    }
  ensure
    file.close if(file)
  end
  def poll_sources(&block)
    load_sources { |source|
      source.poll(&block)
    }
  end
end
  end
end
