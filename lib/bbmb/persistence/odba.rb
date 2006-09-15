#!/usr/bin/env ruby
# Persistence::ODBA -- bbmb.ch -- 14.09.2006 -- hwyss@ywesee.com

require 'bbmb/config'
require 'odba/connection_pool'
require 'odba/drbwrapper'
require 'bbmb/persistence/odba/model/product'
require 'bbmb/persistence/odba/model/user'

module BBMB
  module Persistence
    module ODBA
      def ODBA.save(obj)
        obj.odba_store
      end
    end
  end
  ODBA.storage.dbi = ODBA::ConnectionPool.new("DBI:pg:#{@config.db_name}",
                                             @config.db_user, @config.db_auth)
  ODBA.cache.setup
end
