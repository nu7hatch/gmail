$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubygems'
require 'rspec'
require 'yaml'
require 'gmail'

RSpec.configure do |config|
  config.mock_framework = :rspec
end

def within_gmail(&block)
  gmail = Gmail.connect!(*TEST_ACCOUNT)
  yield gmail if block_given?
  gmail.logout if gmail
end

def mock_client(&block)
  client = Gmail.connect!(*TEST_ACCOUNT)
  yield client if block_given?
  client.logout
end

# Run test by creating your own test account with credentials in account.yml
TEST_ACCOUNT = YAML.load_file(File.join(File.dirname(__FILE__), 'account.yml'))