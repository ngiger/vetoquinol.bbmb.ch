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
        import_customers(data)
      when "ywsarti.csv"
        import_products(data)
      end
    }
  end
  def Updater.import_customers(io)
    imported = CustomerImporter.new.import(io)
    BBMB.logger.debug('updater') { "imported %i Customers" % imported }
  end
  def Updater.import_products(io)
    imported = ProductImporter.new.import(io)
    BBMB.logger.debug('updater') { "imported %i Products" % imported }
  end
end
  end
end
