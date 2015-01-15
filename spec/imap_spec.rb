require 'rubygems'
require 'rspec'
require 'net/imap'
require 'gmail/client/imap_extensions'

describe 'imap patch' do

  it 'should not modify arity' do
    old_arity = Net::IMAP::ResponseParser.new.method(:msg_att).arity
    GmailImapExtensions::patch_net_imap_response_parser
    new_arity = Net::IMAP::ResponseParser.new.method(:msg_att).arity

    expect(old_arity).to eq(new_arity)
  end
end
