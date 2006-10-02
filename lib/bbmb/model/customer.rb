#!/usr/bin/env ruby
# Model::Customer -- bbmb.ch -- 14.09.2006 -- hwyss@ywesee.com

require 'thread'
require 'bbmb/model/order'

module BBMB
  module Model
class Customer
  attr_reader :customer_id, :email, :archive
  attr_accessor :address1, :address2, :address3, :canton, :city, :drtitle,
    :ean13, :fax, :firstname, :lastname, :organisation, :phone_business,
    :phone_mobile, :phone_private, :plz, :title
  def initialize(customer_id, email=nil)
    @archive = {}
    @customer_id = customer_id
    @email = email
    @favorites = Order.new(self)
    @protected = {}
  end
  def commit_order!(commit_time = Time.now)
    Thread.exclusive {
      id = @archive.keys.collect { |id| id.to_i }.max.next.to_s
      order = current_order
      order.commit!(id, commit_time)
      @archive.store(id, order)
      @current_order = nil
      order
    }
  end
  def current_order
    @current_order ||= Order.new(self)
  end
  def email=(email)
    if(@email || email)
      raise "Invalid email address: nil" unless email
      ## notify the server of this change, as it affects the user-data
      BBMB.server.rename_user(@email, email)
      @email = email
    end
  end
  def favorites 
    @favorites ||= Order.new(self)
  end
  def order(commit_id)
    @archive[commit_id]
  end
  def orders
    @archive.values
  end
  def protect!(key)
    @protected.store(key, true)
  end
  def protects?(key)
    @protected.fetch(key, false)
  end
  def turnaround
    orders.inject(0) { |memo, order| order.total + memo }
  end
end
  end
end
