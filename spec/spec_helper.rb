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
  yield(gmail)
  gmail.logout if gmail
end

def mock_client(&block) 
  Gmail.connect(*TEST_ACCOUNT) do |client|
    if block_given?
      yield client
      client.logout
    end
  end
end

def mock_mailbox(box="[Google Mail]/Alle Nachrichten", &block)
  mock_client do |client|
    mailbox = subject.new(client.mailbox_controller, box)
    yield mailbox if block_given?
    mailbox
  end
end

# Run test by creating your own test account with credentials in account.yml
TEST_ACCOUNT = YAML.load_file(File.join(File.dirname(__FILE__), 'account.yml'))