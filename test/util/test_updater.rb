#!/usr/bin/env ruby
# Util::TestUpdater -- bbmb.ch -- 14.09.2006 -- hwyss@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path('../../lib', File.dirname(__FILE__))

require 'test/unit'
require 'bbmb/util/updater'
require 'bbmb/util/csv_importer'
require 'stub/persistence'
require 'flexmock'

module BBMB
  module Util
    class TestUpdater < Test::Unit::TestCase
      include FlexMock::TestCase
      def setup
        BBMB.config = config = flexmock('Config')
        importers = {
          'ywsarti.csv' => 'ProductImporter',
          'ywskund.csv' => 'CustomerImporter',
        }
        config.should_receive(:importers).and_return(importers)
      end
      def test_import_customers
        BBMB.logger = flexmock("logger")
        BBMB.logger.should_ignore_missing
        persistence = flexmock("persistence")
        flexstub(CustomerImporter).should_receive(:new).times(1).and_return { 
          importer = flexmock('importer')
          importer.should_receive(:import).times(1).and_return { |io|
            assert_equal('data', io)
          }
          importer
        }
        Updater.import("CustomerImporter", "data")
      end
      def test_import_products
        BBMB.logger = flexmock("logger")
        BBMB.logger.should_ignore_missing
        persistence = flexmock("persistence")
        flexstub(ProductImporter).should_receive(:new).times(1).and_return { 
          importer = flexmock('importer')
          importer.should_receive(:import).times(1).and_return { |io|
            assert_equal('data', io)
          }
          importer
        }
        Updater.import("ProductImporter", "data")
      end
      def test_run__ywskund_csv
        flexstub(Updater).should_receive(:import).times(1).and_return { 
          |importer, data, prs|
          assert_equal("CustomerImporter", importer)
          assert_equal("mockdata", data)
        }
        flexstub(PollingManager).should_receive(:new).and_return { 
          mgr = flexmock("PollingManager")
          mgr.should_receive(:poll_sources).and_return { |block|
            block.call("ywskund.csv", "mockdata")
          }
          mgr
        }
        Updater.run
      end
      def test_run__ywsarti_csv
        flexstub(Updater).should_receive(:import).times(1).and_return { 
          |importer, data, prs|
          assert_equal("ProductImporter", importer)
          assert_equal("mockdata", data)
        }
        flexstub(PollingManager).should_receive(:new).and_return { 
          mgr = flexmock("PollingManager")
          mgr.should_receive(:poll_sources).and_return { |block|
            block.call("ywsarti.csv", "mockdata")
          }
          mgr
        }
        Updater.run
      end
    end
  end
end
