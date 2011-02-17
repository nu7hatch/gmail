require 'spec_helper'

describe "Gmail client" do
  context "on initialize" do
    subject { Gmail::Client }
    it "should set username, password and options" do
      client = subject.new("test@gmail.com", "pass", :foo => :bar)
      client.username.should == "test@gmail.com"
      client.password.should == "pass"
      client.options[:foo].should == :bar
    end
    
    it "should convert simple username to Gmail email" do
      client = subject.new("test", "pass")
      client.username.should == "test@gmail.com"
    end
    
    it "should detect :xoauth option" do
      client = subject.new("foo@gmail.com", "", :xoauth => { :consumer_key => "",
                  :consumer_secret => "",
                  :token => "",
                  :secret => "" })
      client.xoauth.should_not be_nil
      client.options.should be_empty
    end

    it "should detect :xoauth option and keep other options" do
      client = subject.new("foo@gmail.com", "", :foo => :bar, :xoauth => { :consumer_key => "",
                  :consumer_secret => "",
                  :token => "",
                  :secret => "" })
      client.xoauth.should_not be_nil
      client.options.should_not be_empty
      client.options[:foo].should == :bar
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
end
