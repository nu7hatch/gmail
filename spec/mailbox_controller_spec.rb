require 'spec_helper.rb'

describe "Gmail labels" do
  context "instance" do
    subject {
      client = Gmail::Client.new(*TEST_ACCOUNT)
      client.connect
      client.labels
    }
    
    it "should get list of all available labels" do
      labels = subject
      labels.all.should include("INBOX")
    end
    
    it "should be able to check if there is given label defined" do
      labels = subject
      labels.exists?("INBOX").should be_true
      labels.exists?("FOOBAR").should be_false
    end
    
    it "should be able to create given label" do
      labels = subject
      labels.create("MYLABEL")
      labels.exists?("MYLABEL").should be_true
      labels.create("MYLABEL").should be_false
      labels.delete("MYLABEL")
    end
    
    it "should be able to remove existing label" do
      labels = subject
      labels.create("MYLABEL")
      labels.delete("MYLABEL").should be_true
      labels.exists?("MYLABEL").should be_false
      labels.delete("MYLABEL").should be_false
    end
    
    it "should be able to create label with non-ascii characters" do
      labels = subject
      name = Net::IMAP.decode_utf7("TEST &APYA5AD8-") # TEST äöü
      labels.create(name)
      labels.delete(name).should be_true
      labels.exists?(name).should be_false
      labels.delete(name).should be_false
    end
  end
  
  context "mailboxes" do
    subject { Gmail.connect(*TEST_ACCOUNT).labels }
    
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
    end
    
    it "#mailbox! should raise an error for not existing name" do
      lambda {
        mailbox = subject.mailbox!("FOO")
        mailbox.should_not be_kind_of(Gmail::Mailbox)
      }.should raise_error(KeyError)
    end
  end
end