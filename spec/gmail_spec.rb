require 'spec_helper'

TEST_ACCOUNT = ["test.tim.rubygem@gmail.com", "yadayadayada"] 

describe "Gmail client" do
  subject { Gmail::Client }
  
  context "on initialize" do
    it "should set username, password and options" do
      client = subject.new("test@gmail.com", "pass", :foo => :bar)
      client.username.should == "test@gmail.com"
      client.password.should == "pass"
      client.options[:foo].should == :bar
    end
    
    it "should convert simple name to gmail email" do 
      client = subject.new("test", "pass")
      client.username.should == "test@gmail.com"
    end
  end
  
  context "instance" do
    def mock_client(&block) 
      client = Gmail::Client.new(*TEST_ACCOUNT)
      if block_given?
        client.connect
        yield client
        client.logout
      end
      client
    end
   
    it "should connect to GMail IMAP service" do 
      lambda { 
        client = mock_client
        client.connect!.should be_true
      }.should_not raise_error(Gmail::Client::ConnectionError)
    end
    
    it "should properly login to valid GMail account" do
      client = mock_client
      client.connect.should be_true
      client.login.should be_true
      client.should be_logged_in
      client.logout
    end
    
    it "should raise error when given GMail account is invalid and errors enabled" do
      lambda {
        client = Gmail::Client.new("foo", "bar")
        client.connect.should be_true
        client.login!.should_not be_true
      }.should raise_error(Gmail::Client::AuthorizationError)
    end
    
    it "shouldn't login when given GMail account is invalid" do
      lambda {
        client = Gmail::Client.new("foo", "bar")
        client.connect.should be_true
        client.login.should_not be_true
      }.should_not raise_error(Gmail::Client::AuthorizationError)
    end
    
    it "should properly logout from GMail" do 
      client = mock_client
      client.connect
      client.login.should be_true
      client.logout.should be_true
      client.should_not be_logged_in
    end
    
    it "#connection should automatically log in to GMail account when it's called" do
      mock_client do |client|
        client.expects(:login).once.returns(false)
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
    
    context "labels" do
      subject { 
        client = Gmail::Client.new(*TEST_ACCOUNT)
        client.connect
        client.labels
      }
      
      it "should get list of all available labels" do
        labels = subject
        labels.all.should include("TEST", "INBOX")
      end
      
      it "should be able to check if there is given label defined" do
        labels = subject
        labels.exists?("TEST").should be_true
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
    end
  end
end

=begin
class GmailTest < Test::Unit::TestCase
  def test_initialize
    imap = mock('imap')
    Net::IMAP.expects(:new).with('imap.gmail.com', 993, true, nil, false).returns(imap)
    gmail = Gmail.new(*TEST_ACCOUNT)
  end
  
  def test_imap_does_login
    setup_mocks(:at_exit => true)

    #@imap.expects(:disconnected?).at_least_once.returns(true).then.returns(false)
    @imap.expects(:login).with(*TEST_ACCOUNT)
    @gmail.imap
  end

  def test_imap_does_login_only_once
    setup_mocks(:at_exit => true)

    #@imap.expects(:disconnected?).at_least_once.returns(true).then.returns(false)
    @imap.expects(:login).with(*TEST_ACCOUNT)
    @gmail.imap
    @gmail.imap
    @gmail.imap
  end

  def test_imap_does_login_without_appending_gmail_domain
    setup_mocks(:at_exit => true)

    #@imap.expects(:disconnected?).at_least_once.returns(true).then.returns(false)
    @imap.expects(:login).with(*TEST_ACCOUNT)
    @gmail.imap
  end
  
  def test_imap_logs_out
    setup_mocks(:at_exit => true)

    #@imap.expects(:disconnected?).at_least_once.returns(true).then.returns(false)
    @imap.expects(:login).with(*TEST_ACCOUNT)
    @gmail.imap
    @imap.expects(:logout).returns(true)
    @gmail.logout
  end

  def test_imap_logout_does_nothing_if_not_logged_in
    setup_mocks

    #@imap.expects(:disconnected?).returns(true)
    @imap.expects(:logout).never
    @gmail.logout
  end
  
  def test_imap_calls_create_label
    setup_mocks(:at_exit => true)
    #@imap.expects(:disconnected?).at_least_once.returns(true).then.returns(false)
    @imap.expects(:login).with(*TEST_ACCOUNT)
    @imap.expects(:create).with('foo')
    @gmail.create_label('foo')
  end
  
  private
  def setup_mocks(options = {})
    options = {:at_exit => false}.merge(options)
    @imap = mock('imap')
    Net::IMAP.expects(:new).with('imap.gmail.com', 993, true, nil, false).returns(@imap)
    @gmail = Gmail.new(*TEST_ACCOUNT)
    
    # need this for the at_exit block that auto-exits after this test method completes
    @imap.expects(:logout).at_least(0) if options[:at_exit]
  end
end
=end
