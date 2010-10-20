require 'spec_helper'

describe "A Gmail mailbox" do
  subject { Gmail::Mailbox }
  
  def within_gmail(&block) 
    gmail = Gmail.connect!(*TEST_ACCOUNT)
    yield(gmail)
    gmail.logout if gmail
  end
  
  context "on initialize" do
    it "should set client and name" do
      within_gmail do |gmail|
        mailbox = subject.new(gmail, "TEST")
        mailbox.instance_variable_get("@gmail").should == gmail
        mailbox.name.should == "TEST"
      end
    end
    
    it "name should be INBOX by default" do
      within_gmail do |gmail|
        mailbox = subject.new(@gmail)
        mailbox.name.should == "INBOX"
      end
    end
  end
  
  context "instance" do
    def mock_mailbox(box="INBOX", &block)
      within_gmail do |gmail|
        mailbox = subject.new(gmail, box)
        yield(mailbox) if block_given?
        mailbox
      end
    end
    
    it "should be able to count all emails" do
      mock_mailbox do |mailbox|
        mailbox.count.should > 0
      end
    end
    
  end
end
