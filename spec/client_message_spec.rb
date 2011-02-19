require 'spec_helper'

describe Gmail::Client, "message deliver feature" do
  it "should properly compose message" do
    mail = mock_client.compose do
      from "test@gmail.com"
      to "friend@gmail.com"
      subject "Hello world!"
    end
    mail.from.should == ["test@gmail.com"]
    mail.to.should == ["friend@gmail.com"]
    mail.subject.should == "Hello world!"
  end
  
  it "#compose should automatically add `from` header when it is not specified" do
    mail = mock_client.compose
    mail.from.should == [TEST_ACCOUNT[0]]
    mail = mock_client.compose(Mail.new)
    mail.from.should == [TEST_ACCOUNT[0]]
    mail = mock_client.compose {}
    mail.from.should == [TEST_ACCOUNT[0]]
  end
  
  it "should deliver inline composed email" do
    mock_client do |client|
      client.deliver do
        to TEST_ACCOUNT[0]
        subject "Hello world!"
        body "Yeah, hello there!"
      end.should be_true
    end
  end
  
  it "should not raise error when mail can't be delivered and errors are disabled" do
    lambda {
      client = mock_client
      client.deliver(Mail.new {}).should be_false
    }.should_not raise_error(Gmail::Client::DeliveryError)
  end
  
  it "should raise error when mail can't be delivered and errors are disabled" do
    lambda {
      client = mock_client
      client.deliver!(Mail.new {})
    }.should raise_error(Gmail::Client::DeliveryError)
  end
end