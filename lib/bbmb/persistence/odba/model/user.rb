#!/usr/bin/env ruby
# Model::User -- bbmb.ch -- 14.09.2006 -- hwyss@ywesee.com

require 'bbmb/model/user'

module BBMB
  module Model
    class User 
      include ODBA::Persistable
      odba_index :customer_id
    end
  end
end
