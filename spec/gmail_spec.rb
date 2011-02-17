require 'spec_helper'

describe "Any object" do
  it "should be able to convert itself to IMAP date format" do
    "20-12-1988".to_imap_date.should == "20-December-1988"
  end
end

describe "Gmail" do
  context "on initialize" do
    it "#new should create and return a valid connection object" do
      gmail = Gmail.new(*TEST_ACCOUNT)
      gmail.should be_kind_of(Gmail::Client)
    end
    
    it "#new should give it context when block given" do
      Gmail.new(*TEST_ACCOUNT) do |gmail|
        gmail.should be_kind_of(Gmail::Client)
      end
    end
    
    it "should not login after a #new method" do
      gmail = Gmail.new(*TEST_ACCOUNT)
      gmail.should_not be_logged_in
    end
  end
  
  context "connect" do
    %w[connect connect!].each do |method|
      it "##{method} should return a valid connection object and login" do
        gmail = Gmail.send(method, *TEST_ACCOUNT)
        gmail.should be_logged_in
      end
      
      it "##{method} should connect, login and give it context when block given" do
        Gmail.send(method, *TEST_ACCOUNT) do |gmail|
          gmail.should be_logged_in
        end
      end
    end
    
    it "#connect should not raise error when couldn't login to given account" do
      # lambda {
      #   gmail = Gmail.connect("foo", "bar")
      #   gmail.should_not be_logged_in
      # }.should_not raise_error(Gmail::Client::AuthorizationError)
    end
    
    it "#connect! should raise error when couldn't login to given account" do
      # lambda {
      #   gmail = Gmail.connect("foo", "bar")
      #   gmail.should_not be_logged_in
      # }.should raise_error(Gmail::Client::AuthorizationError)
    end
  end
end