require 'spec_helper'

describe Gmail::MailboxController, "instance" do
  subject { @controller ||= mock_client.mailbox_controller }
  
  it "should get list of all available mailboxes" do
    subject.labels.should include("INBOX")
  end
  
  it "should be able to check if a given mailbox defined" do
    subject.exists?("INBOX").should be_true
    subject.exists?("FOOBAR").should be_false
  end
  
  it "should be able to create given label" do
    subject.create("MYLABEL")
    subject.exists?("MYLABEL").should be_true
    subject.create("MYLABEL").should be_false
    subject.delete("MYLABEL")
  end
  
  it "should be able to remove existing label" do
    subject.create("MYLABEL")
    subject.delete("MYLABEL").should be_true
    subject.exists?("MYLABEL").should be_false
    subject.delete("MYLABEL").should be_false
  end
  
  it "should be able to create label with non-ascii characters" do
    name = Net::IMAP.decode_utf7("TEST &APYA5AD8-") # TEST äöü
    subject.create(name)
    subject.delete(name).should be_true
    subject.exists?(name).should be_false
    subject.delete(name).should be_false
  end
  
  it "should alias the right default mailboxes" do
    MAILBOX_ALIASES.each do |k, v|
      subject.send(k).should be_kind_of(Gmail::Mailbox)
      subject.send(k).name.should == v
    end
  end
  
  %w[mailbox mailbox!].each do |method|
    it "##{method} should return INBOX if no name was given" do
      mailbox = subject.send(method)
      mailbox.should be_kind_of(Gmail::Mailbox)
      mailbox.name.should == "INBOX"
    end
    
    it "##{method} should return a mailbox with given name" do
      mailbox = subject.send(method, "TEST")
      mailbox.should be_kind_of(Gmail::Mailbox)
      mailbox.name.should == "TEST"
    end
    
    it "##{method} should return a mailbox with given name using block style" do
      subject.send(method, "TEST") do |mailbox|
        mailbox.should be_kind_of(Gmail::Mailbox)
        mailbox.name.should == "TEST"
      end
    end
    
    it "##{method} should return a system mailbox for given symbol" do
      MAILBOX_ALIASES.each do |k, v|
        subject.send(method, k) do |mailbox|
          mailbox.should be_kind_of(Gmail::Mailbox)
          mailbox.name.should == v
        end
      end
    end
  end
  
  it "#mailbox! should raise an error for not existing name" do
    lambda {
      mailbox = subject.mailbox!("FOO")
      mailbox.should_not be_kind_of(Gmail::Mailbox)
    }.should raise_error(KeyError)
  end
end