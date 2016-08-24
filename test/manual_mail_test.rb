#!/usr/bin/env ruby
# encoding: utf-8

require "iconv"
require "openssl"
require "ydim/config"
require "ydim/client"
require "bbmb"
require "bbmb/util/numbers"
require "bbmb/model/order"
require "bbmb/config"

class ConnectChecker

  def initialize
    @iconv = Iconv.new('ISO-8859-1//TRANSLIT//IGNORE', 'UTF-8')
  end

  def invoice
    owed = BBMB::Util::Money.new(nil)
    time       = Time.now
    time_range = (Time.now - 3)..(Time.now - 1)
    format = BBMB.config.invoice_item_format
    baseline = BBMB::Util::Money.new(BBMB.config.invoice_monthly_baseline)
    baseamount = BBMB::Util::Money.new(BBMB.config.invoice_monthly_baseamount)
    connect do |client|
      inv = client.create_invoice(BBMB.config.ydim_id)
      inv.description = sprintf(BBMB.config.invoice_format,
                                  time_range.first.strftime("%d.%m.%Y"),
                                  (time_range.last - 1).strftime("%d.%m.%Y"))
      inv.date           = Date.today
      inv.currency       = "CHF"
      inv.payment_period = 30
      items = []
      item_format = @iconv.iconv(BBMB.config.invoice_item_format)
      item_args = [2]
      time = Time.now
      if baseamount > 0
        item_format = @iconv.iconv(BBMB.config.invoice_item_overrun_format)
        basepart = [baseline, owed].min
        text = sprintf(BBMB.config.invoice_item_baseline_format,
                       basepart, owed, *item_args)
        item_data = {
          :price    => baseamount.to_f,
          :quantity => 1,
          :text     => @iconv.iconv(number_format(text)),
          :time     => time,
          :unit     => @iconv.iconv(BBMB.config.invoice_item_baseamount_unit),
        }
        item_args.unshift owed
        items.push item_data
      end
      if owed > baseline
        owed -= baseline
        text = sprintf(item_format, owed, *item_args)
        item_data = {
          :price    =>  owed.to_f * BBMB.config.invoice_percentage / 100,
          :quantity =>  1,
          :text     =>  @iconv.iconv(number_format(text)),
          :time     =>  Time.local(date.year, date.month, date.day),
          :unit     =>  "%0.1f%" % BBMB.config.invoice_percentage,
        }
        items.push item_data
      end
    end
  end

  private

  def connect(&block)
    require 'pry'; binding.pry
    config = YDIM::Client::CONFIG
    if(path = BBMB.config.ydim_config)
      config.load(path)
    end
    server = DRbObject.new(nil, config.server_url)
    client = YDIM::Client.new(config)
    key = OpenSSL::PKey::DSA.new(File.read(config.private_key))
    client.login(server, key)
    p "connect!!"
    #block.call(client)
  ensure
    client.logout if(client)
  end

  def orders(range=(0..10))
    BBMB.persistence.all(BBMB::Model::Order).select { |order|
      p order
      order.commit_time && range.include?(order.commit_time)
    }
  end
end

checker = ConnectChecker.new
checker.invoice
