require 'spec_helper'

describe Gmail::MessageComposer do
  before(:all) do
    @client = Gmail.connect!(*TEST_ACCOUNT)
  end
  
  after(:all) do
    @client.logout
    @client = nil
  end
  
  subject { Gmail::MessageComposer.new(@client) }
  
  it "should properly compose message" do
    mail = subject.compose do
      from "test@gmail.com"
      to "friend@gmail.com"
      subject "Hello world!"
    end
    mail.from.should == ["test@gmail.com"]
    mail.to.should == ["friend@gmail.com"]
    mail.subject.should == "Hello world!"
  end
  
  it "#compose should automatically add `from` header when it is not specified" do
    mail = subject.compose
    mail.from.should == [TEST_ACCOUNT[0]]
    mail = subject.compose(Mail.new)
    mail.from.should == [TEST_ACCOUNT[0]]
    mail = subject.compose {}
    mail.from.should == [TEST_ACCOUNT[0]]
  end
  
  it "should deliver inline composed email" do
    subject.should_receive(:deliver).once.and_return(true)
    subject.deliver do
      to TEST_ACCOUNT[0]
      subject "Hello world!"
      body "Yeah, hello there!"
    end.should be_true
  end
  
  it "should not raise error when mail can't be delivered and errors are disabled" do
    lambda {
      subject.deliver(Mail.new {}).should be_false
    }.should_not raise_error(Gmail::Client::DeliveryError)
  end
  
  it "should raise error when mail can't be delivered and errors are disabled" do
    lambda {
      subject.deliver!(Mail.new {})
    }.should raise_error(Gmail::Client::DeliveryError)
  end
end