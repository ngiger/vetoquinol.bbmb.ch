#!/usr/bin/env ruby
# Util::TestUpdater -- bbmb.ch -- 14.09.2006 -- hwyss@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path('../../lib', File.dirname(__FILE__))

require 'test/unit'
require 'bbmb/util/updater'
require 'persistence/test'
require 'flexmock'

module BBMB
  module Util
    class TestUpdater < Test::Unit::TestCase
      include FlexMock::TestCase
      def test_import_users
        persistence = flexmock("persistence")
        flexstub(UserImporter).should_receive(:new).times(1).and_return { 
          importer = flexmock('importer')
          importer.should_receive(:import).times(1).and_return { |io|
            assert_equal('data', io)
          }
          importer
        }
        Updater.import_users("data")
      end
      def test_import_products
        persistence = flexmock("persistence")
        flexstub(ProductImporter).should_receive(:new).times(1).and_return { 
          importer = flexmock('importer')
          importer.should_receive(:import).times(1).and_return { |io|
            assert_equal('data', io)
          }
          importer
        }
        Updater.import_products("data")
      end
      def test_run__ywskund_csv
        flexstub(Updater).should_receive(:import_users).times(1).and_return { 
          |data, prs|
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
        flexstub(Updater).should_receive(:import_products).times(1).and_return { 
          |data, prs|
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
