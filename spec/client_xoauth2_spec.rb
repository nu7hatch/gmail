require 'spec_helper'

describe "Gmail client (XOAuth2)" do
  subject { Gmail::Client::XOAuth2 }

  context "on initialize" do
    it "should set username, oauth2_token and options" do
      client = subject.new("test@gmail.com", {
        :token => "token",
        :foo   => :bar
      })
      client.username.should == "test@gmail.com"
      client.token.should == {:token=>"token", :foo=>:bar}
    end

    it "should convert simple name to gmail email" do
      client = subject.new("test", {:token => "token"})
      client.username.should == "test@gmail.com"
    end
  end

  context "instance" do
    def mock_client(&block) 
      client = Gmail::Client::XOAuth2.new(*TEST_ACCOUNT)
      if block_given?
        client.connect
        yield client
        client.logout
      end
      client
    end

    it "should connect to GMail IMAP service" do 
      expect(->{
        client = mock_client
        client.connect!.should be_truthy
      }).to_not raise_error
    end

    it "should properly login to valid GMail account" do
      pending
      client = mock_client
      client.connect.should be_truthy
      client.login.should be_truthy
      client.should be_logged_in
      client.logout
    end

    it "should raise error when given GMail account is invalid and errors enabled" do
      expect(->{
        client = Gmail::Client::XOAuth2.new("foo", {:token=>"bar"})
        client.connect.should be_truthy
        client.login!.should_not be_truthy
      }).to raise_error(Gmail::Client::AuthorizationError)
    end

    it "shouldn't login when given GMail account is invalid" do
      expect(->{
        client = Gmail::Client::XOAuth2.new("foo", {:token=>"bar"})
        client.connect.should be_truthy
        client.login.should_not be_truthy
      }).to_not raise_error
    end

    it "should properly logout from GMail" do
      pending
      client = mock_client
      client.connect
      client.login.should be_truthy
      client.logout.should be_truthy
      client.should_not be_logged_in
    end

    it "#connection should automatically log in to GMail account when it's called" do
      mock_client do |client|
        expect(client).to receive(:login).once.and_return(false)
        client.connection.should_not be_nil
      end
    end

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
      pending
      mock_client do |client|
        client.deliver do
          to TEST_ACCOUNT[0]
          subject "Hello world!"
          body "Yeah, hello there!"
        end.should be_truthy
      end
    end

    it "should not raise error when mail can't be delivered and errors are disabled" do
      expect(->{
        client = mock_client
        client.deliver(Mail.new {}).should be_falsey
      }).to_not raise_error
    end

    it "should raise error when mail can't be delivered and errors are disabled" do
      expect(->{
        client = mock_client
        client.deliver!(Mail.new {})
      }).to raise_error(Gmail::Client::DeliveryError)
    end

    it "should properly switch to given mailbox" do
      pending
      mock_client do |client|
        mailbox = client.mailbox("TEST")
        mailbox.should be_kind_of(Gmail::Mailbox)
        mailbox.name.should == "TEST"
      end
    end

    it "should properly switch to given mailbox using block style" do
      pending
      mock_client do |client|
        client.mailbox("TEST") do |mailbox|
          mailbox.should be_kind_of(Gmail::Mailbox)
          mailbox.name.should == "TEST"
        end
      end
    end

    context "labels" do
      subject {
        client = Gmail::Client::XOAuth2.new(*TEST_ACCOUNT)
        client.connect
        client.labels
      }

      it "should get list of all available labels" do
        pending
        labels = subject
        labels.all.should include("TEST", "INBOX")
      end

      it "should be able to check if there is given label defined" do
        pending
        labels = subject
        labels.exists?("TEST").should be_truthy
        labels.exists?("FOOBAR").should be_falsey
      end

      it "should be able to create given label" do
        pending
        labels = subject
        labels.create("MYLABEL")
        labels.exists?("MYLABEL").should be_truthy
        labels.create("MYLABEL").should be_falsey
        labels.delete("MYLABEL")
      end

      it "should be able to remove existing label" do
        pending
        labels = subject
        labels.create("MYLABEL")
        expect(labels.delete("MYLABEL")).to be_truthy
        expect(labels.exists?("MYLABEL")).to be_falsey
        expect(labels.delete("MYLABEL")).to be_falsey
      end
    end
  end
end
