$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubygems'
require 'rspec'
require 'yaml'
require 'gmail'

RSpec.configure do |config|
  config.mock_framework = :rspec
end

# Run test by creating your own test account with credentials in account.yml
TEST_ACCOUNT = YAML.load_file(File.join(File.dirname(__FILE__), 'account.yml'))
MAILBOX_ALIASES = YAML.load_file(File.join(File.dirname(__FILE__), 'mailbox_de.yml'))