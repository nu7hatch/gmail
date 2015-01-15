require 'spec_helper'

describe Gmail::Message do
  
  let(:uid) { 123456 }
  subject do
    message = nil
    live_mailbox do |mailbox|
      message = Gmail::Message.new(mailbox, uid)
    end
    message
  end
  let(:mock_subject){ Gmail::Message.new(nil, nil) }

  describe "initialize" do
    it "should set uid and mailbox" do
      subject.instance_variable_get(:@mailbox).should be_a Gmail::Mailbox
      subject.instance_variable_get(:@gmail).should be_a Gmail::Client::Base
      subject.instance_variable_get(:@uid).should eq uid
      subject.labels
    end
  end

  describe "instance" do

    describe "#mark" do
      it "should be able to mark itself as read" do
        mock_subject.expects(:read!).with().once
        mock_subject.mark(:read)
      end

      it "should be able to mark itself as unread" do
        mock_subject.expects(:unread!).with().once
        mock_subject.mark(:unread)
      end

      it "should be able to mark itself as deleted" do
        mock_subject.expects(:delete!).with().once
        mock_subject.mark(:deleted)
      end

      it "should be able to mark itself as spam" do
        mock_subject.expects(:spam!).with().once
        mock_subject.mark(:spam)
      end

      it "should be able to mark itself with a flag" do
        mock_subject.expects(:flag).with(:my_flag).once
        mock_subject.mark(:my_flag)
      end
    end

    describe "#read!" do
      it "should flag itself as :Seen" do
        mock_subject.expects(:flag).with(:Seen).once
        mock_subject.read!
      end
    end

    describe "#unread!" do
      it "should unflag :Seen from itself" do
        mock_subject.expects(:unflag).with(:Seen).once
        mock_subject.unread!
      end
    end

    describe "#star!" do
      it "should flag itself as '[Gmail]/Starred'" do
        mock_subject.expects(:flag).with('[Gmail]/Starred').once
        mock_subject.star!
      end
    end

    describe "#unstar!" do
      it "should unflag '[Gmail]/Starred' from itself" do
        mock_subject.expects(:unflag).with('[Gmail]/Starred').once
        mock_subject.unstar!
      end
    end

    describe "#spam!" do
      it "should move itself to '[Gmail]/Spam'" do
        mock_subject.expects(:move_to).with('[Gmail]/Spam').once
        mock_subject.spam!
      end
    end

    ## TODO FIXME: This test passes but should be reviewed in next patch of lib/gmail/message.rb
    ## that reviews the `#move_to` method
    describe "#archive!" do
      it "should move itself to '[Gmail]/All Mail'" do
        mock_subject.expects(:move_to).with('[Gmail]/All Mail').once
        mock_subject.archive!
      end
    end

    ## TODO FIXME: This test only passes if ran against a patched lib/gmail/message.rb 
    it "should be able to set given label" do
      live_mailbox('[Gmail]/All Mail') do |mailbox|
        mailbox.emails(:unread, :from => TEST_ACCOUNT[0].to_s, :subject => "Hello world!").should_not be_empty
        mailbox.emails(:unread, :from => TEST_ACCOUNT[0].to_s, :subject => "Hello world!").each do |em|
          em.add_label 'Awesome'
          em.add_label 'Great'
          em.labels.should include("Awesome")
          em.labels.should include("Great")
          em.labels.should include(:Inbox)
        end
      end
    end

    ## TODO FIXME: This test only passes if ran against a patched lib/gmail/message.rb 
    it "should remove a given label" do
      live_mailbox('[Gmail]/All Mail') do |mailbox|
        mailbox.emails(:unread, :from => TEST_ACCOUNT[0].to_s, :subject => "Hello world!").should_not be_empty
        mailbox.emails(:unread, :from => TEST_ACCOUNT[0].to_s, :subject => "Hello world!").each do |em|
          em.remove_label 'Awesome'
          em.labels.should_not include("Awesome")
          em.labels.should include("Great")
          em.labels.should include(:Inbox)
          em.flags.should_not include(:Seen)
        end
      end
    end

    ## TODO FIXME: This test will fail and can be removed when the patch it comes with is applied
    it "should be able to set given label with old method" do
      live_mailbox('[Gmail]/All Mail') do |mailbox|
        mailbox.emails(:unread, :from => TEST_ACCOUNT[0].to_s, :subject => "Hello world!").should_not be_empty
        mailbox.emails(:unread, :from => TEST_ACCOUNT[0].to_s, :subject => "Hello world!").each do |em|
          em.label! 'Awesome'
          em.label! 'Great'
          em.labels.should include("Great")
          em.labels.should include("Awesome")
          em.labels.should include(:Inbox)
        end
      end
    end

    ## TODO FIXME: This test will fail and can be removed when the patch it comes with is applied
    it "should remove a given label with old method" do
      live_mailbox('[Gmail]/All Mail') do |mailbox|
        mailbox.emails(:unread, :from => TEST_ACCOUNT[0].to_s, :subject => "Hello world!").should_not be_empty
        mailbox.emails(:unread, :from => TEST_ACCOUNT[0].to_s, :subject => "Hello world!").each do |em|
          em.remove_label! 'Awesome'
          em.labels.should_not include("Awesome")
          em.labels.should include("Great")
          em.labels.should include(:Inbox)
          em.flags.should_not include(:Seen)
        end
      end
    end
    
    ## TODO FIXME: This test will fail unless the failing tests 
    ## related to the old method of adding/removing label are removed
    it "should be able to mark itself with given flag" do
      live_mailbox('[Gmail]/All Mail') do |mailbox|
        mailbox.emails(:unread, :from => TEST_ACCOUNT[0].to_s, :subject => "Hello world!").should_not be_empty
        mailbox.emails(:unread, :from => TEST_ACCOUNT[0].to_s, :subject => "Hello world!").each do |em|
          em.mark(:Seen)
          em.flags.should include(:Seen)
        end
      end
    end
    
    # TODO FIXME: This test is failing and needs fixing `#move_to` in lib/gmail/message.rb to pass
    it "should be able to move itself to given box" do
      live_mailbox('[Gmail]/All Mail') do |mailbox|
        mailbox.emails(:read, :from => TEST_ACCOUNT[0].to_s, :subject => "Hello world!").should_not be_empty
        mailbox.emails(:read, :from => TEST_ACCOUNT[0].to_s, :subject => "Hello world!").each do |em|
          em.mark(:unread)
          em.move_to 'TEST'
          em.labels.should include('TEST')
        end
      end
    end

    it "should be able to delete itself" do
      pending
    end
  end 
end
