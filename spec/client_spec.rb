require 'spec_helper'

describe "Gmail client" do
  context "on initialize" do
    subject { Gmail::Client }
    it "should set username, password and options" do
      client = subject.new("test@gmail.com", "pass", :foo => :bar)
      client.username.should == "test@gmail.com"
      client.password.should == "pass"
      client.connection.options[:foo].should == :bar
    end
    
    it "should convert simple username to Gmail email" do
      client = subject.new("test", "pass")
      client.username.should == "test@gmail.com"
    end
    
    it "should detect :xoauth option" do
      client = subject.new("foo@gmail.com", :xoauth => { :consumer_key => "",
                  :consumer_secret => "",
                  :token => "",
                  :secret => "" })
      client.connection.authentication.should == :xoauth
      client.connection.options.should be_empty
    end

    it "should detect :xoauth option and keep other options" do
      client = subject.new("foo@gmail.com", :foo => :bar, :xoauth => { :consumer_key => "",
                  :consumer_secret => "",
                  :token => "",
                  :secret => "" })
      client.connection.authentication.should == :xoauth
      client.connection.options.should_not be_empty
      client.connection.options[:foo].should == :bar
    end
    
    it "should not login on initialize" do
      client = subject.new("test", "pass")
      client.should_not be_logged_in
    end
  end
  
  context "instance" do
    subject { Gmail::Client.new(*TEST_ACCOUNT) }
    
    it "should connect to Gmail IMAP service" do 
      lambda { 
         subject.connect!.should be_true
      }.should_not raise_error(Gmail::Client::ConnectionError)
    end
    
    it "should properly login to a valid Gmail account" do
      subject.connect.should be_true
      subject.login.should be_true
      subject.should be_logged_in
      subject.logout
    end
    
    it "should raise error when given Gmail account is invalid and errors enabled" do
      lambda {
        client = Gmail::Client.new("foo", "bar")
        client.connect.should be_true
        client.login!.should_not be_true
      }.should raise_error(Gmail::Client::AuthorizationError)
    end
    
    it "shouldn't login when given Gmail account is invalid" do
      lambda {
        client = Gmail::Client.new("foo", "bar")
        client.connect.should be_true
        client.login.should_not be_true
      }.should_not raise_error(Gmail::Client::AuthorizationError)
    end
    
    it "should properly logout from GMail" do 
      subject.connect
      subject.login.should be_true
      subject.logout.should be_true
      subject.should_not be_logged_in
    end
  end
  
  context "labels" do
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
    
    it "should return mailbox with given label" do
      pending
    end
  end
end