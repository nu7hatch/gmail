$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubygems'
require 'rspec'
require 'mocha'
require 'yaml'
require 'gmail'

RSpec.configure do |config| 
  config.mock_with :mocha
end

def within_gmail(&block)
  gmail = Gmail.connect!(*TEST_ACCOUNT)
  yield(gmail)
  gmail.logout if gmail
end

def mock_mailbox(box="INBOX", &block)
  within_gmail do |gmail|
    mailbox = subject.new(gmail, box)
    yield(mailbox) if block_given?
    mailbox
  end
end

# Run test by creating your own test account with credentials in account.yml
TEST_ACCOUNT = YAML.load_file(File.join(File.dirname(__FILE__), 'account.yml'))