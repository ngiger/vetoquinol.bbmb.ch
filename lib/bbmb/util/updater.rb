#!/usr/bin/env ruby
# Util::Updater -- bbmb.ch -- 14.09.2006 -- hwyss@ywesee.com

require 'bbmb'
require 'bbmb/util/csv_importer'
require 'bbmb/util/polling_manager'

module BBMB
  module Util
    module Updater
      def Updater.run
        PollingManager.new.poll_sources { |filename, data|
          case filename
          when "ywskund.csv"
            import_users(data)
          when "ywsarti.csv"
            import_products(data)
          end
        }
      end
      def Updater.import_users(io)
        UserImporter.new.import(io)
      end
      def Updater.import_products(io)
        ProductImporter.new.import(io)
      end
    end
  end
end
