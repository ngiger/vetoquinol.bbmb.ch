#!/usr/bin/env ruby
# Selenium::TestCustomer -- bbmb.ch -- 04.10.2006 -- hwyss@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path('../lib', File.dirname(__FILE__))

require 'selenium/unit'

module BBMB
  module Selenium
class TestCustomer < Test::Unit::TestCase
  include Selenium::TestCase
  def test_customer
    customer = BBMB::Model::Customer.new('007')
    customer.organisation = 'Test-Customer'
    customer.instance_variable_set('@email', 'test.customer@bbmb.ch')
    customer.plz = '7777'
    @persistence.should_receive(:all).and_return { |klass|
      assert_equal(BBMB::Model::Customer, klass)
      [customer]
    }
    user = login_admin
    @selenium.click "link=Test-Customer"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "BBMB | Kunde", @selenium.get_title

    assert_equal "Kunde*", @selenium.get_text("//label[@for='organisation']")
    assert @selenium.is_element_present("organisation")
    assert_equal "Test-Customer", @selenium.get_value("organisation")

    assert_equal "Kundennr*", @selenium.get_text("//label[@for='customer_id']")
    assert @selenium.is_element_present("customer_id")
    assert_equal "007", @selenium.get_value("customer_id")

    assert_equal "EAN-Code", @selenium.get_text("//label[@for='ean13']")
    assert @selenium.is_element_present("ean13")

    assert_equal "Umsatz", @selenium.get_text("//label[@for='turnaround']")
    assert @selenium.is_element_present("link=Sfr. 0.00")
    url = "http://vetoquinol.bbmb.ch.localhost:10080/de/orders/customer_id/007"
    assert_equal url, @selenium.get_attribute("//a[@name='turnaround']@href")

    assert @selenium.is_element_present("link=Umsatz")
    assert @selenium.is_text_present("Sfr. 0.00 - Umsatz")
    assert_equal "Anrede", @selenium.get_text("//label[@for='title']")
    assert @selenium.is_element_present("title")
    assert_equal "Titel", @selenium.get_text("//label[@for='drtitle']")
    assert @selenium.is_element_present("drtitle")
    assert_equal "Name", @selenium.get_text("//label[@for='lastname']")
    assert @selenium.is_element_present("lastname")
    assert_equal "Vorname", @selenium.get_text("//label[@for='firstname']")
    assert @selenium.is_element_present("firstname")
    assert_equal "Adresse*", @selenium.get_text("//label[@for='address1']")
    assert @selenium.is_element_present("address1")
    assert @selenium.is_element_present("address2")
    assert @selenium.is_element_present("address3")
    assert_equal "PLZ", @selenium.get_text("//label[@for='plz']")
    assert @selenium.is_element_present("plz")
    assert_equal "Ort", @selenium.get_text("//label[@for='city']")
    assert @selenium.is_element_present("city")
    assert @selenium.is_text_present("PLZ/Ort")
    assert_equal "Kanton", @selenium.get_text("//label[@for='canton']")
    assert @selenium.is_element_present("canton")

    assert_equal "Email*", @selenium.get_text("//label[@for='email']")
    assert @selenium.is_element_present("email")
    assert_equal "test.customer@bbmb.ch", @selenium.get_value("email")

    assert_equal "Tel. Geschäft", @selenium.get_text("//label[@for='phone_business']")
    assert @selenium.is_element_present("phone_business")
    assert_equal "Tel. Privat", @selenium.get_text("//label[@for='phone_private']")
    assert @selenium.is_element_present("phone_private")
    assert_equal "Tel. Mobile", @selenium.get_text("//label[@for='phone_mobile']")
    assert @selenium.is_element_present("phone_mobile")
    assert_equal "Fax", @selenium.get_text("//label[@for='fax']")
    assert @selenium.is_element_present("fax")

    assert @selenium.is_element_present("change_password")
    assert @selenium.is_element_present("generate_pass")
    assert !@selenium.is_element_present("pass")
    assert !@selenium.is_element_present("confirm_pass")

    assert @selenium.is_element_present("save")
    assert_equal "Speichern", @selenium.get_value("save")
  end
  def test_customer__save_errors
    BBMB.server = flexmock('server')
    BBMB.server.should_ignore_missing
    BBMB.persistence.should_ignore_missing
    customer = BBMB::Model::Customer.new('007')
    customer.organisation = 'Test-Customer'
    customer.instance_variable_set('@email', 'test.customer@bbmb.ch')
    customer.plz = '7777'
    @persistence.should_receive(:all).and_return { |klass|
      assert_equal(BBMB::Model::Customer, klass)
      [customer]
    }
    user = login_admin
    @selenium.click "link=Test-Customer"
    @selenium.wait_for_page_to_load "30000"

    @selenium.click "change_password"
    @selenium.wait_for_page_to_load "30000"

    assert @selenium.is_text_present("Das Benutzerprofil wurde nicht gespeichert!")

    @selenium.type "ean13", "768012345678"
    @selenium.click "save"
    @selenium.wait_for_page_to_load "30000"

    assert @selenium.is_text_present("Das Benutzerprofil wurde nicht gespeichert!")
    assert @selenium.is_text_present("Das Passwort war leer.")
    assert_equal "error", @selenium.get_attribute("//label[@for='address1']@class")
    assert_equal "error", @selenium.get_attribute("//label[@for='pass']@class")
    assert_equal "error", @selenium.get_attribute("//label[@for='confirm_pass']@class")
    assert_equal "error", @selenium.get_attribute("//label[@for='ean13']@class")

    @selenium.type "address1", "Address"
    @selenium.type "pass", "secret"
    @selenium.type "confirm_pass", "terces"
    @selenium.click "save"
    @selenium.wait_for_page_to_load "30000"

    assert @selenium.is_text_present("Das Benutzerprofil wurde nicht gespeichert!")
    assert @selenium.is_text_present("Das Passwort und die Bestätigung waren nicht identisch.")
    assert @selenium.is_text_present("Der EAN-Code war ungültig.")
  end
  def test_customer__save
    BBMB.server = flexmock('server')
    BBMB.server.should_ignore_missing
    BBMB.persistence.should_ignore_missing
    customer = BBMB::Model::Customer.new('007')
    customer.organisation = 'Test-Customer'
    customer.instance_variable_set('@email', 'test.customer@bbmb.ch')
    customer.plz = '7777'
    @persistence.should_receive(:all).and_return { |klass|
      assert_equal(BBMB::Model::Customer, klass)
      [customer]
    }
    user = login_admin
    user.should_receive(:get_preference).and_return('')

    @selenium.click "link=Test-Customer"
    @selenium.wait_for_page_to_load "30000"

    @selenium.click "change_password"
    @selenium.wait_for_page_to_load "30000"

    @selenium.type "ean13", "7680123456781"
    @selenium.type "address1", "Address"
    @selenium.type "pass", "secret"
    @selenium.type "confirm_pass", "secret"

    entity = flexmock('yus-entity')
    entity.should_receive(:valid?).and_return(true)
    user.should_receive(:grant).times(1).and_return { |email, action, item|
      assert_equal('login', action)
      assert_equal('ch.bbmb.Customer', item)
    }
    user.should_receive(:set_password).times(1).and_return { |email, hash|
      assert_equal('test.customer@bbmb.ch', email)
      assert_equal(Digest::MD5.hexdigest('secret'), hash)
      @yus_entities.store(email, entity)
    }

    @selenium.click "save"
    @selenium.wait_for_page_to_load "30000"

    assert !@selenium.is_text_present("Das Benutzerprofil wurde nicht gespeichert!")
    assert @selenium.is_element_present("change_password")
    assert @selenium.is_element_present("generate_pass")
    assert_equal "Passwort ändern", @selenium.get_value("change_password")
  end
  def test_customer__duplicate_email
    BBMB.server = flexmock('server')
    BBMB.server.should_receive(:rename_user).and_return { |old, new|
      raise Yus::YusError, 'duplicate email'
    }
    BBMB.server.should_ignore_missing
    BBMB.persistence.should_ignore_missing
    customer = BBMB::Model::Customer.new('007')
    customer.organisation = 'Test-Customer'
    customer.plz = '7777'
    @persistence.should_receive(:all).and_return { |klass|
      assert_equal(BBMB::Model::Customer, klass)
      [customer]
    }
    user = login_admin
    user.should_receive(:get_preference).and_return('')

    @selenium.click "link=Test-Customer"
    @selenium.wait_for_page_to_load "30000"

    @selenium.click "change_password"
    @selenium.wait_for_page_to_load "30000"

    @selenium.type "email", "test.user@bbmb.ch"
    @selenium.type "address1", "Address"
    @selenium.type "pass", "secret"
    @selenium.type "confirm_pass", "secret"

    entity = flexmock('yus-entity')
    entity.should_receive(:valid?).and_return(true)

    @selenium.click "save"
    @selenium.wait_for_page_to_load "30000"

    assert @selenium.is_text_present("Das Benutzerprofil wurde nicht gespeichert!")
    assert @selenium.is_text_present("Es gibt bereits ein Benutzerprofil für diese Email-Adresse")
  end
  def test_customer__password_not_set
    BBMB.server = flexmock('server')
    BBMB.server.should_receive(:rename_user)
    BBMB.server.should_ignore_missing
    BBMB.persistence.should_ignore_missing
    customer = BBMB::Model::Customer.new('007')
    customer.organisation = 'Test-Customer'
    customer.plz = '7777'
    @persistence.should_receive(:all).and_return { |klass|
      assert_equal(BBMB::Model::Customer, klass)
      [customer]
    }
    user = login_admin
    user.should_receive(:get_preference).and_return('')
    user.should_receive(:grant)
    user.should_receive(:set_password).and_return { |old, new|
      raise Yus::YusError, 'other error, user not found, privilege problem'
    }

    @selenium.click "link=Test-Customer"
    @selenium.wait_for_page_to_load "30000"

    @selenium.click "change_password"
    @selenium.wait_for_page_to_load "30000"

    @selenium.type "email", "test.user@bbmb.ch"
    @selenium.type "address1", "Address"
    @selenium.type "pass", "secret"
    @selenium.type "confirm_pass", "secret"

    entity = flexmock('yus-entity')
    entity.should_receive(:valid?).and_return(true)

    @selenium.click "save"
    @selenium.wait_for_page_to_load "30000"

    assert @selenium.is_text_present("Das Benutzerprofil wurde nicht gespeichert!")
    assert @selenium.is_text_present("Das Passwort konnte nicht gespeichert werden")
  end
  def test_customer__generate_pass
    BBMB.server = flexmock('server')
    BBMB.server.should_ignore_missing
    BBMB.persistence.should_ignore_missing
    customer = BBMB::Model::Customer.new('007')
    customer.organisation = 'Test-Customer'
    customer.instance_variable_set('@email', 'test.customer@bbmb.ch')
    customer.drtitle = 'Dr. med. vet.'
    customer.firstname = 'firstname'
    customer.lastname = 'lastname'
    customer.plz = '7777'
    customer.city = 'city'
    customer.ean13 = "7680123456781"
    customer.address1 = "Address"
    @persistence.should_receive(:all).and_return { |klass|
      assert_equal(BBMB::Model::Customer, klass)
      [customer]
    }

    user = login_admin
    user.should_receive(:get_preference).and_return('')
    entity = flexmock('yus-entity')
    entity.should_receive(:valid?).and_return(true)
    @yus_entities.store(customer.email, entity)

    @selenium.click "link=Test-Customer"
    @selenium.wait_for_page_to_load "30000"

    flexstub(Util::PasswordGenerator).should_receive(:generate).and_return 'pass'

    user.should_receive(:set_password).times(1).and_return { |email, hash|
      assert_equal('test.customer@bbmb.ch', email)
      assert_equal(Digest::MD5.hexdigest('pass'), hash)
      @yus_entities.store(email, entity)
    }

    @selenium.click "generate_pass"
    @selenium.wait_for_page_to_load "30000"

    assert !@selenium.is_text_present("Das Benutzerprofil wurde nicht gespeichert!")
    assert @selenium.is_element_present("change_password")
    assert(@selenium.is_element_present("generate_pass") \
           || @selenium.is_element_present("show_pass"))
  end
end
  end
end
