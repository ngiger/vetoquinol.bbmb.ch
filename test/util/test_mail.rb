#!/usr/bin/env ruby
# encoding: utf-8
$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path('..', File.dirname(__FILE__))

require 'test_helper'

require 'bbmb/config'
require 'bbmb/util/mail'
require 'stub/persistence'
require 'flexmock/minitest'
require 'minitest/autorun'
require 'bbmb/util/csv_importer'

$default_config = BBMB.config.clone

module BBMB
  module Util
    class TestMail <  ::Minitest::Test
      def setup
        super
        BBMB.config = $default_config.clone
        Model::Customer.clear_instances
        BBMB.server = flexmock('server')
        BBMB.server.should_ignore_missing
        @mail_file = File.expand_path(File.join(__FILE__, '..', '..', 'data', 'gmail.txt'))
      end
      def teardown
        BBMB.config = $default_config.clone
        ::Mail.defaults do  delivery_method :test end
        super
      end
      def setup_config
        config = BBMB.config
        config.mail_suppress_sending = true
        config.error_recipients = [TestRecipient]
        config.mail_order_from = 'from.test@bbmb.ch'
        config.mail_order_to = TestRecipient
        config.mail_order_subject = 'order %s'
        config.mail_request_from = 'from.request.test@bbmb.ch'
        config.mail_request_to = 'to.request.test@bbmb.ch'
        config.mail_request_cc = 'cc.request.test@bbmb.ch'
        config.mail_request_subject = 'Request %s'
        config.name = 'Application/User Agent'
        config.smtp_pass = 'secret'
        config.smtp_port = 25
        config.smtp_server = 'mail.test.com'
        config.smtp_user = 'user'
        config.mail_confirm_reply_to = 'replyto-test@bbmb.ch'
        config.mail_confirm_from = 'from-test@bbmb.ch'
        config.mail_confirm_cc = []
        config.mail_confirm_subject = 'Confirmation %s'
        config.mail_confirm_body = <<-EOS
Sie haben am %s folgende Artikel bestellt:

%s
------------------------------------------------------------------------
Bestelltotal exkl. Mwst. %10.2f
Bestelltotal inkl. Mwst. %10.2f
====================================

En date du %s vous avez commandé les articles suivants

%s
------------------------------------------------------------------------
Commande excl. Tva.      %10.2f
Commande incl. Tva.      %10.2f
====================================

In data del %s Lei ha ordinato i seguenti prodotti.

%s
------------------------------------------------------------------------
Totale dell'ordine escl. %10.2f
Totale dell'ordine incl. %10.2f
====================================
        EOS
        config.mail_confirm_lines = [
          "%3i x %-36s à %7.2f, total  %10.2f",
          "%3i x %-36s à %7.2f, total  %10.2f",
          "%3i x %-36s a %7.2f, totale %10.2f",
        ]
        config.inject_error_to = TestRecipient
        config.confirm_error_to = TestRecipient
        config
      end
      # This test verifies, that we decode a correct gmail mesage
      def test_reading_gmail
        file = File.expand_path(File.join(__FILE__, '..', '..', 'data', 'gmail.txt'))
        mail = ::Mail.new(File.read(file))
        assert_equal('Fichiers eShop JDE', mail.subject)
        assert_equal(2, mail.attachments.size)
        assert_equal('ywsarti.csv', mail.attachments[0].filename)
        assert_equal('ywskund.csv', mail.attachments[1].filename)
        File.open("tst0.txt", 'w+') {|f| f.write mail.attachments[0].body.decoded }
        File.open("tst1.txt", 'w+') {|f| f.write mail.attachments[1].body.decoded }
        assert_equal('gesperrt;0100551;0340096957147;Corebral inj 50ml fr;;26.6000;;;;;;;;;3;;;;;;;;;;;VETOQU;112;;12;23.9000;0;0;0;0;0;0;0;0;0;0;;no', mail.attachments[0].body.decoded.split("\n")[0])
        assert_equal('16654;1061;;VETOQU;;VETOQUINOL AG (BARBARA);;;;;3063;ITTIGEN;       031 818 56 56;;;       031 818 56 50; ', mail.attachments[1].body.decoded.split("\n")[0])
        assert_equal(File.read('tst0.txt'), File.read(file.sub('gmail.txt', 'ywsarti.csv')))
        assert_equal(File.read('tst1.txt'), File.read(file.sub('gmail.txt', 'ywskund.csv')), 'ywskund.csv must match')
      end
      def test_reading_ywsarti_csv
        id = '0100815'
        importer = ProductImporter.new
        persistence = flexmock("persistence")
        article_0100815 = flexmock(Model::Product, 'article_0100815')
        persistence.should_receive(:save).and_return do |article|
          assert_instance_of(Model::Product, article)
          assert_equal(id, article.article_number)
          assert_equal("Dopram v inj 20ml fr", article.description.de)
          assert_equal("0340096867763", article.ean13)
        end
        persistence.should_receive(:all).and_return([article_0100815])
        article_file = File.expand_path(File.join(File.dirname(__FILE__), '..', 'data', 'ywsarti.csv'))
        src = File.read(article_file, :encoding => 'iso-8859-1')
        test_articles = []
        src.split("\n").each do |line|
          test_articles << line if /;0100551;|;#{id};/.match(line)
        end
        res = importer.import(StringIO.new(test_articles.join("\n")), persistence)
        assert_equal(2, res) # imported one active and one gesperrt article
        assert_equal( { id => true}, importer.active_products)
      end
      def test_reading_ywskun_csv
        importer = CustomerImporter.new
        persistence = flexmock("persistence")
        persistence.should_receive(:save).and_return { |customer_16659|
          assert_instance_of(Model::Customer, customer_16659)
          assert_equal("16659", customer_16659.customer_id)
          assert_equal('', customer_16659.drtitle)
          assert_equal("ANIMANS / MANSER BARBARA UND CHLÄUS", customer_16659.organisation)
          assert_equal("MED. VET.", customer_16659.address1)
          assert_equal("BARBARA UND CHLÄUS MANSER", customer_16659.address2)
          assert_equal('', customer_16659.address3)
          assert_equal("1784", customer_16659.plz)
          assert_equal("COURTEPIN", customer_16659.city)
          assert_equal("026 684 11 24", customer_16659.phone_business)
          assert_equal('', customer_16659.phone_private)
          assert_equal('', customer_16659.phone_mobile)
          assert_equal('', customer_16659.fax)
          assert_equal('', customer_16659.email)
        }
        customer_file = File.expand_path(File.join(File.dirname(__FILE__), '..', 'data', 'ywskund.csv'))
        src = File.read(customer_file, :encoding => 'iso-8859-1')

        test_customers = []
        src.split("\n").each do |line|
          test_customers << line if /16659/.match(line)
        end
        importer.import(StringIO.new(test_customers.join("\n")), persistence)
      end
    end
  end
end
