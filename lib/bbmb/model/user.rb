#!/usr/bin/env ruby
# Model::User -- bbmb.ch -- 14.09.2006 -- hwyss@ywesee.com

module BBMB
  module Model
    class User
      attr_reader :customer_id
      attr_accessor :address1, :address2, :address3, :comport, :customer_ean13,
        :drtitle, :email, :fax, :firstname, :gender, :kanton,
        :lastname, :location, :organisation, :phone_business, :phone_mobile,
        :phone_private, :plz
      def initialize(customer_id)
        @customer_id = customer_id
      end
    end
  end
end
