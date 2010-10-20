$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubygems'
require 'rspec'
require 'mocha'
require 'gmail'

RSpec.configure do |config| 
  config.mock_with :mocha
end

TEST_ACCOUNT = ["test@gmail.com", "test"]
