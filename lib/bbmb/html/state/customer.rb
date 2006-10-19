#!/usr/bin/env ruby
# Html::State::Customer -- bbmb.ch -- 19.09.2006 -- hwyss@ywesee.com

require 'bbmb/html/state/global'
require 'bbmb/html/state/show_pass'
require 'bbmb/html/view/customer'
require 'bbmb/util/password_generator'
require 'ostruct'

module BBMB
  module Html
    module State
class Customer < Global
  attr_reader :cleartext
  mandatory :address1, :email, :organisation, :customer_id
  VIEW = View::Customer
  def init
    @model = Model::Customer.find_by_customer_id(@session.user_input(:customer_id))
  end
  def direct_argument_keys
    [:customer_id]
  end
  def direct_event
    unless(error? || @session.event == :change_pass)
      [ :customer, {:customer_id => @model.customer_id} ]
    end
  end
  def generate_pass
    _save
    if(@model.email)
      @cleartext = BBMB::Util::PasswordGenerator.generate(@model)
      passhash = @session.validate(:pass, @cleartext)
      begin
        @session.user.set_password(@model.email, passhash)
      rescue Yus::YusError
        @errors.store(:pass, create_error(:e_pass_not_set, :pass, nil))
      end
    else
      error = create_error(:e_email_required, :email, @model.email)
      @errors.store(:email, error)
      @errors.store(:pass, error)
    end
    self
  end
  def mandatory
    mandatory = _mandatory
    if(set_pass? || @session.user_input(:pass))
      mandatory += [:pass, :confirm_pass]
    end
    mandatory
  end
  def update_user(input)
    email = input.delete(:email)
    @model.email = email
    @model.protect!(:email)
    if(passhash = input.delete(:confirm_pass))
      begin
        @session.user.grant(email, 'login', 
                          BBMB.config.auth_domain + '.Customer')
        @session.user.set_password(email, passhash)
      rescue Yus::YusError => e 
        @errors.store(:pass, create_error(:e_pass_not_set, :email, email))
      end
    end
  rescue Yus::YusError
    @errors.store(:email, create_error(:e_duplicate_email, :email, email))
  end
  def save
    _save
    self
  end
  alias :change_pass :save
  def _save
    keys = mandatory + [ :ean13, :title, :drtitle, :lastname, :firstname,
                         :address2, :address3, :plz, :city, :canton,
                         :phone_business, :phone_private, :phone_mobile, :fax ]
    input = user_input(keys, mandatory)
    update_user(input)
    if(error?)
      @errors.store(:error, create_error(:error, :error, nil))
      @errors.store(:e_user_unsaved, create_error(:e_user_unsaved, :error, nil))
    else
      input.each { |key, val| 
        writer = "#{key}="
        if(@model.respond_to?(writer) && @model.send(key) != val)
          @model.send(writer, val)
          @model.protect!(key)
        end
      }
      BBMB.persistence.save(@model)
    end
  end
  def set_pass?
    !@session.user.entity_valid?(@model.email) \
      || @session.error(:pass) || @session.error(:confirm_pass)
  end
  def show_pass
    model = OpenStruct.new
    model.cleartext = @cleartext
    model.email = @model.email
    model.address_lines = @model.address_lines
    @cleartext = nil
    ShowPass.new(@session, model)
  end
end
    end
  end
end
