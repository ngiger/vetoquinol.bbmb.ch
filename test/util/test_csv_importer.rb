#!/usr/bin/env ruby
# Util::TestUpdater -- bbmb.ch -- 14.09.2006 -- hwyss@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path('../../lib', File.dirname(__FILE__))

require 'test/unit'
require 'bbmb/util/csv_importer'
require 'persistence/test'
require 'flexmock'

module BBMB
  module Util
    class TestCsvImporter < Test::Unit::TestCase
      def test_string
        importer = CsvImporter.new
        assert_nil(importer.string(''))
        assert_equal(u("\303\244\303\266\303\274"), importer.string('äöü'))
      end
    end
    class TestUserImporter < Test::Unit::TestCase
      include FlexMock::TestCase
      def setup
        Model::User.clear_instances
      end
      def test_import
        src = <<-EOS
15047;1061;;VETOQU;Herr Dr.med.vet.;Aeberhard Ueli;Gemeindehausplatz 4;rue strasse;;;5323;BERNE;;;;; 
15048;1061;;VETOQU;Herr Dkr;FARMACIA SAN ROCCO SA;PIAZZA SIMEN 7;;;;6500;BELLINZONA;;;;; 
15050;1061;;VETOQU;Herr Dr.med.vet.;Holliger Rudolf;Boniswilerstrasse 8;;;;5707;Seengen;;;;; 
15055;1061;;VETOQU;Herr Dr.med.vet.;Minder H.P.;Schäfliwiese 13;;;;9306;Freidorf TG;;;;; 
15057;1061;;VETOQU;;ESSAI;RUE DES FINCELLES;;;;4355;LURE;;;;; 
15065;1061;;VETOQU;;Apotheke Bahnhof;Frankfurt Platze;;;;8790;Zurich;;;;; 
15073;1061;;VETOQU;;ESSAI AYT DT TVS;RUE DES FINCELLES;;;;4355;LURE;;;;; 
15074;1061;;VETOQU;;ESSAI NON AYT DT;RUE DES FINCELLES;;;;4355;LURE;;;;; 
15075;1061;;VETOQU;;Client Suisse AD-TVS;8, Friedrich Strasse;;;;8900;Zurich;;;;089065789; 
15078;1061;;VETOQU;;CLIENT SUISSE AYANT DROIT TVS;RUE DE BERN;;;;3123;BELP;;;;00 41 31 818 56 50; 
        EOS
        persistence = flexmock("persistence")
        persistence.should_receive(:save).times(10).with(Model::User)
        UserImporter.new.import(src, persistence)
      end
      def test_import_record
        line = <<-EOS
15047;1061;;VETOQU;Herr Dr.med.vet.;Aeberhard Ueli;Gemeindehausplatz 4;rue strasse;address3;;5323;BERNE;business;mobile;private;fax;email
        EOS
        importer = UserImporter.new
        record = CSV.parse_line(line, ";")
        user = importer.import_record(record)
        assert_instance_of(Model::User, user)
        assert_equal("15047", user.customer_id)
        assert_equal("Herr Dr.med.vet.", user.drtitle)
        assert_equal("Aeberhard Ueli", user.organisation)
        assert_equal("Gemeindehausplatz 4", user.address1)
        assert_equal("rue strasse", user.address2)
        assert_equal("address3", user.address3)
        assert_equal("5323", user.plz)
        assert_equal("BERNE", user.location)
        assert_equal("business", user.phone_business)
        assert_equal("private", user.phone_private)
        assert_equal("mobile", user.phone_mobile)
        assert_equal("fax", user.fax)
        assert_equal("email", user.email)
        assert_equal(user, importer.import_record(record))
      end
    end
    class TestProductImporter < Test::Unit::TestCase
      include FlexMock::TestCase
      def setup
        Model::Product.clear_instances
      end
      def test_import
        src = <<-EOS
gesperrt;0101387;0340096716076;Lacrybiotic pom opht 10g;;0;;;;;;;;;Y;;;;;;;;;;;VETOQU;112;;0;0;0;0;0;0;0;0;0;0;0;0;;yes
gesperrt;0101904;0340096849529;Neomycine hydroc pom 10g;;0;;;;;;;;;Y;;;;;;;;;;;VETOQU;112;;0;0;0;0;0;0;0;0;0;0;0;0;;yes
gesperrt;0104203;;Marbocyl 5mg cpr bt100;;0;;;;;;;;;Y;;;;;;;;;;;VETOQU;112;;0;0;0;0;0;0;0;0;0;0;0;0;;no
gesperrt;0104313;0340096760657;Marbocyl 10% sol 100ml;;25.5000;;;;;;;;;Y;;;;;;;;;;;VETOQU;112;;0;0;0;0;0;0;0;0;0;0;0;0;;yes
gesperrt;0300212;;Arthri dog cpr bt40 ch;;0;;;;;;;;;Y;;;;;;;;;;;VETOQU;112;;0;0;0;0;0;0;0;0;0;0;0;0;;no
gesperrt;0300619;;Calmivet cpr bt40 ch;;0;;;;;;;;;Y;;;;;;;;;;;VETOQU;112;;0;0;0;0;0;0;0;0;0;0;0;0;;no
gesperrt;0301862;;Energidex sol inj 500ml ch;;0;;;;;;;;;Y;;;;;;;;;;;VETOQU;112;;0;0;0;0;0;0;0;0;0;0;0;0;;no
gesperrt;0302467;;Hydrocortiderm 60g ch;;0;;;;;;;;;Y;;;;;;;;;;;VETOQU;112;;0;0;0;0;0;0;0;0;0;0;0;0;;no
gesperrt;0303292;;Megecat cpr bt18 ch;;0;;;;;;;;;Y;;;;;;;;;;;VETOQU;112;;0;0;0;0;0;0;0;0;0;0;0;0;;no
gesperrt;0303688;;Oribiotic pom 10g ch;;0;;;;;;;;;Y;;;;;;;;;;;VETOQU;112;;0;0;0;0;0;0;0;0;0;0;0;0;;no
        EOS
        persistence = flexmock("persistence")
        persistence.should_receive(:save).times(10).with(Model::Product)
        ProductImporter.new.import(src, persistence)
      end
      def test_import_record
        line = <<-EOS
gesperrt;0313720;;Marbocyl 10% sol 50ml ch;;8.6500;;;;;;;;;3;;;;;;;;;;;VETOQU;112;;0;0;0;0;0;0;0;0;0;0;0;0;;no
        EOS
        record = CSV.parse_line(line, ";")
        product = ProductImporter.new.import_record(record)
        assert_instance_of(Model::Product, product)
        assert_equal("0313720", product.article_number)
        assert_equal("gesperrt", product.status)
        assert_nil(product.ean13)
        assert_equal("Marbocyl 10% sol 50ml ch", product.description)
        assert_equal(3, product.mwst)
        assert_nil(product.pcode)
        assert_equal(0, product.l1_qty)
        assert_equal(0, product.l1_price)
        assert_equal(0, product.l2_qty)
        assert_equal(0, product.l2_price)
        assert_equal(0, product.l3_qty)
        assert_equal(0, product.l3_price)
        assert_equal(0, product.l4_qty)
        assert_equal(0, product.l4_price)
        assert_equal(0, product.l5_qty)
        assert_equal(0, product.l5_price)
        assert_equal(0, product.l6_qty)
        assert_equal(0, product.l6_price)
      end
      def test_import_record__ean
        line = <<-EOS
gesperrt;0801031;0340117772763;Equi biotin forte 1 kg;;0;;;;;;;;;3;;;;;;;;;;;VETOQU;112;;0;0;0;0;0;0;0;0;0;0;0;0;;no
        EOS
        record = CSV.parse_line(line, ";")
        product = ProductImporter.new.import_record(record)
        assert_instance_of(Model::Product, product)
        assert_equal("0801031", product.article_number)
        assert_equal("gesperrt", product.status)
        assert_equal("0340117772763", product.ean13)
        assert_equal("Equi biotin forte 1 kg", product.description)
      end
    end
  end
end
