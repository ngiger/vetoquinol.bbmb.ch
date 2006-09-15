#!/usr/bin/env ruby
# @config -- bbmb.ch -- 08.09.2006 -- hwyss@ywesee.com

require 'rclconf'

module BBMB
  default_dir = File.expand_path('../etc', ENV['DOCUMENT_ROOT'])
  default_config_files = [
    File.join(default_dir, 'bbmb.yml'),
    '/etc/bbmb/bbmb.yml',
  ]
  defaults = {
    'bbmb_dir'          => File.expand_path('..', default_dir),
    'config'			      => default_config_files,
    'data_dir'          => File.expand_path('../data', default_dir),
    'db_name'           => 'bbmb',
    'db_user'           => 'bbmb',
    'db_auth'           => 'bbmb',
    'db_backend'        => :psql,
    'error_recipients'  => [],
    'log_file'          => STDERR,
    'log_level'         => 'INFO',
    'persistence'       => 'odba',
    'server_url'        => 'druby://localhost:12000',
    'update?'           => true,
    'update_hour'       => 23,
  }

  config = RCLConf::RCLConf.new(ARGV, defaults)
  config.load(config.config)
  @config = config
end
