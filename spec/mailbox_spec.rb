require 'spec_helper'

describe "A Gmail mailbox" do
  subject { Gmail::Mailbox }

  context "on initialize" do
    it "should set client and name" do
      within_gmail do |gmail|
        mailbox = subject.new(gmail, "TEST")
        mailbox.instance_variable_get("@gmail").should == gmail
        mailbox.name.should == "TEST"
      end
    end

    it "should work in INBOX by default" do
      within_gmail do |gmail|
        mailbox = subject.new(@gmail)
        mailbox.name.should == "INBOX"
      end
    end
  end

  context "instance" do

    it "should be able to count all emails" do
      mock_mailbox do |mailbox|
        mailbox.count.should > 0
      end
    end

    it "should be able to find messages" do
      mock_mailbox do |mailbox|
        message  = mailbox.emails.first
        mailbox.emails(:all, :from => message.from.first) == message.from.first
      end
    end
  end
end
