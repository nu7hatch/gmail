require 'spec_helper'

describe Gmail::Message do

  let(:uid) { 123456 }
  subject do
    live_mailbox do |mailbox|
      return Gmail::Message.new(mailbox, uid)
    end
  end
  let(:mock_subject){ Gmail::Message.new(nil, nil) }

  describe "initialize" do
    it "should set uid and mailbox" do
      subject.instance_variable_get(:@mailbox).should be_a Gmail::Mailbox
      subject.instance_variable_get(:@gmail).should be_a Gmail::Client::Base
      subject.instance_variable_get(:@uid).should eq uid
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

    describe "#archive!" do
      it "should move itself to '[Gmail]/All Mail'" do
        mock_subject.expects(:move_to).with('[Gmail]/All Mail').once
        mock_subject.archive!
      end
    end

    describe "#remove_label!" do
      it "should move itself to '[Gmail]/All Mail' from the original label" do
        mock_subject.expects(:move_to).with('[Gmail]/All Mail', 'original').once
        mock_subject.remove_label! 'original'
      end
    end

    it "should be able to delete itself" do
      pending
    end

    it "should be able to set given label" do
      pending
    end
    
    it "should be able to mark itself with given flag" do
      pending
    end
    
    it "should be able to move itself to given box" do
      pending
    end
  end 
end
