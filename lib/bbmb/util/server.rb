#!/usr/bin/env ruby
# Util::Server -- de.bbmb.org -- 01.09.2006 -- hwyss@ywesee.com

require 'bbmb/util/updater'
require 'date'
require 'sbsm/drbserver'

module BBMB
  module Util
    class Server < SBSM::DRbServer
      ENABLE_ADMIN = true 
      attr_reader :updater
      def run_updater
        @updater = Thread.new {
          loop {
            day = Date.today
            now = Time.now
            if(now.hour >= BBMB.config.update_hour)
              day += 1
            end
            at = Time.local(day.year, day.month, day.day, 
                            BBMB.config.update_hour)
            sleep(at - now)
            update
          }
        }
      end
      def update
        Updater.run
      rescue Exception => e

      end
    end
  end
end
