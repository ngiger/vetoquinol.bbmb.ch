require 'pathname'

root_dir = Pathname.new(__FILE__).realpath.parent.parent
lib_dir  = root_dir.join('lib')
test_dir = root_dir.join('test')

$:.unshift(root_dir) unless $:.include?(root_dir)
$:.unshift(lib_dir)  unless $:.include?(lib_dir)
$:.unshift(test_dir) unless $:.include?(test_dir)

require 'flexmock/minitest'
require 'minitest/autorun'
require 'bbmb/config'

# We create hier a global copy of the defautl BBMB.config as we
# must restore it after each change in BBMB.config in a test
$default_config = BBMB.config.clone

require 'mail'
::Mail.defaults do delivery_method :test end
  TestRecipient = 'to.test@bbmb.ch'
::Mail::TestMailer.deliveries.clear

Dir[root_dir.join('test/support/**/*.rb')].each { |f| require f }
