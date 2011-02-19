require 'spec_helper'

describe "A Gmail mailbox" do
  context "on initialize" do
    subject { Gmail::Mailbox }
    
    it "should set controller and name" do
      mock_client do |client|
        mailbox = subject.new(client.mailbox_controller, "TEST")
        mailbox.instance_variable_get("@controller").should == client.mailbox_controller
        mailbox.name.should == "TEST"
      end
    end
    
    it "should work in INBOX by default" do
      mock_client do |client|
        mailbox = subject.new(client.mailbox_controller)
        mailbox.name.should == "INBOX"
      end
    end
  end
  
  context "instance" do
    subject { Gmail.connect!(*TEST_ACCOUNT).all_mail }
    
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