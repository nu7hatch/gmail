require 'spec_helper'

describe "Any object" do
  it "should be able to convert itself to IMAP date format" do
    "20-12-1988".to_imap_date.should == "20-December-1988"
  end
  
  %w[new new!].each do |method|
    it "##{method} should properly connect with GMail service and return valid connection object" do
      gmail = Gmail.send(method, *TEST_ACCOUNT)
      gmail.should be_kind_of(Gmail::Client::Plain)
      gmail.connection.should_not be_nil
      gmail.should be_logged_in
    end
    
    it "##{method} should connect with client and give it context when block given" do
      Gmail.send(method, *TEST_ACCOUNT) do |gmail|
        gmail.should be_kind_of(Gmail::Client::Plain)
        gmail.connection.should_not be_nil
        gmail.should be_logged_in
      end
    end
  end
  
  it "#new should not raise error when couldn't connect with given account" do
    lambda { 
      gmail = Gmail.new("foo", "bar")
      gmail.should_not be_logged_in 
    }.should_not raise_error
  end

  it "#new! should raise error when couldn't connect with given account" do
    lambda { 
      gmail = Gmail.new!("foo", "bar")
      gmail.should_not be_logged_in 
    }.should raise_error      
      ### FIX: can someone dig to the bottom of this?  We are getting NoMethodError instead of Gmail::Client::AuthorizationError in 1.9
  end
end
