$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubygems'
require 'rspec'
require 'yaml'
require 'gmail'

RSpec.configure do |config|
  config.mock_framework = :rspec
end

def mock_client(&block)
  client = Gmail.connect!(*TEST_ACCOUNT)
  if block_given?
    yield client
    client.logout
  end
  client
end
alias :within_gmail :mock_client

# Run test by creating your own test account with credentials in account.yml
TEST_ACCOUNT = YAML.load_file(File.join(File.dirname(__FILE__), 'account.yml'))
MAILBOX_ALIASES = YAML.load_file(File.join(File.dirname(__FILE__), 'mailbox_de.yml'))