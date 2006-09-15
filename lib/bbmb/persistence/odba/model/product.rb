#!/usr/bin/env ruby
# Model::Product -- bbmb.ch -- 14.09.2006 -- hwyss@ywesee.com

require 'bbmb/model/product'

module BBMB
  module Model
    class Product
      include ODBA::Persistable
      odba_index :article_number
      odba_index :article_ean13
      odba_index :article_descr
      odba_index :article_pcode
    end
  end
end
