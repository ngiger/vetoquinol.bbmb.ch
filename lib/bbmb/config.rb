#!/usr/bin/env ruby
# @config -- bbmb.ch -- 08.09.2006 -- hwyss@ywesee.com

require 'rclconf'
require 'bbmb'

module BBMB
  default_dir = if(root =  ENV['DOCUMENT_ROOT'])
                  File.expand_path('../etc', root)
                elsif(home = ENV['HOME'])
                  File.expand_path('.bbmb/etc', home)
                else
                  require 'tmpdir'
                  Dir.tmpdir
                end
  default_config_files = [
    File.join(default_dir, 'bbmb.yml'),
    '/etc/bbmb/bbmb.yml',
  ]
  defaults = {
    'admins'            => [],
    'auth_domain'       => 'ch.bbmb',
    'auth_url'          => 'druby://localhost:12001',
    'bbmb_dir'          => File.expand_path('..', default_dir),
    'config'			      => default_config_files,
    'data_dir'          => File.expand_path('../data', default_dir),
    'db_name'           => 'bbmb',
    'db_user'           => 'bbmb',
    'db_auth'           => 'bbmb',
    'db_backend'        => :psql,
    'debug'             => false,
    'error_recipients'  => [],
    'http_server'       => 'http://www.bbmb.ch',
    'log_file'          => STDERR,
    'log_level'         => 'INFO',
    'mail_order_cc'     => [],
    'mail_order_from'   => 'orders.test@bbmb.ch',
    'mail_order_subject'=> 'Bbmb-Order %s',
    'mail_order_to'     => 'orders.test@bbmb.ch',
    'persistence'       => 'odba',
    'polling_file'      => File.expand_path('polling.yml', default_dir),
    'server_url'        => 'druby://localhost:12000',
    'session_timeout'   => 3600,
    'smtp_authtype'     => nil,
    'smtp_helo'         => 'localhost.localdomain',
    'smtp_pass'         => nil,
    'smtp_port'         => 25,
    'smtp_server'       => 'mail.bbmb.ch',
    'smtp_user'         => nil,
    'update?'           => true,
    'update_hour'       => 23,
  }

  config = RCLConf::RCLConf.new(ARGV, defaults)
  config.load(config.config)
  @config = config
end
