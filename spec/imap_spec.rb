require 'rubygems'
require 'rspec'
require 'net/imap'
require 'gmail/client/imap_extensions'

describe 'imap patch' do

  it 'should not modify arity' do
    GmailImapExtensions::patch_net_imap_response_parser
    expect(Net::IMAP::ResponseParser.new).to respond_to(:msg_att).with(0).arguments
    expect(Net::IMAP::ResponseParser.new).to respond_to(:msg_att).with(1).arguments
  end
end
