require 'spec_helper'

describe "A Gmail mailbox" do
  before(:all) do
    @client = Gmail.connect!(*TEST_ACCOUNT)
  end
  
  after(:all) do
    @client.logout
    @client = nil
  end
  
  context "on initialize" do
    subject { Gmail::Mailbox }
    
    it "should set controller and name" do
      mailbox = subject.new(@client.mailbox_controller, "TEST")
      mailbox.instance_variable_get("@controller").should == @client.mailbox_controller
      mailbox.name.should == "TEST"
    end
    
    it "should work in INBOX by default" do
      mailbox = subject.new(@client.mailbox_controller)
      mailbox.name.should == "INBOX"
    end
  end
  
  context "instance" do
    subject { @client.all_mail }
    
    it "should be able to count all emails" do
      subject.count.should > 0
    end
    
    it "should be able to find messages" do
      pending "Wait for refactor Gmail::Message"
      # mock_mailbox do |mailbox|
      #   message = mailbox.emails.first
      #   mailbox.emails(:all, :from => message.from.first.name) == message.from.first.name
      # end
    end
    
    it "should be able to do a full text search of message bodies" do
      pending "This can wait..."
      #mock_mailbox do |mailbox|
      #  message = mailbox.emails.first
      #  body = message.parts.blank? ? message.body.decoded : message.parts[0].body.decoded
      #  emails = mailbox.emails(:search => body.split(' ').first)
      #  emails.size.should > 0
      #end
    end
  end
end