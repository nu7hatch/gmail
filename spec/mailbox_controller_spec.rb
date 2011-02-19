require 'spec_helper.rb'

describe "Gmail mailbox controller" do
  context "instance" do
    subject { Gmail.connect(*TEST_ACCOUNT).mailbox_controller }
    
    it "should get list of all available mailboxes" do
      labels = subject.all.map {|m| m.imap_path}
      labels.should include("INBOX")
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
      # subject.create(name)
      # subject.delete(name).should be_true
      # subject.exists?(name).should be_false
      # subject.delete(name).should be_false
    end
  end
  
  # context "mailboxes" do
  #   subject { Gmail.connect(*TEST_ACCOUNT).mailbox_controller }
  #   
  #   %w[mailbox mailbox!].each do |method|
  #     it "##{method} should return INBOX if no name was given" do
  #       mailbox = subject.send(method)
  #       mailbox.should be_kind_of(Gmail::Mailbox)
  #       mailbox.name.should == "INBOX"
  #     end
  #     
  #     it "##{method} should return a mailbox with given name" do
  #       mailbox = subject.send(method, "TEST")
  #       mailbox.should be_kind_of(Gmail::Mailbox)
  #       mailbox.name.should == "TEST"
  #     end
  #     
  #     it "##{method} should return a mailbox with given name using block style" do
  #       subject.send(method, "TEST") do |mailbox|
  #         mailbox.should be_kind_of(Gmail::Mailbox)
  #         mailbox.name.should == "TEST"
  #       end
  #     end
  #   end
  #   
  #   it "#mailbox! should raise an error for not existing name" do
  #     lambda {
  #       mailbox = subject.mailbox!("FOO")
  #       mailbox.should_not be_kind_of(Gmail::Mailbox)
  #     }.should raise_error(KeyError)
  #   end
  # end
end