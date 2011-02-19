require 'mime/message'

module Gmail
  class Message
    # Raised when given label doesn't exists.
    class NoLabelError < KeyError; end
    
    attr_reader :uid, :mailbox
    def initialize(mailbox, uid)
      @uid     = uid
      @mailbox = mailbox
    end
    
    def uid
      @uid ||= mailbox.controller.uid_search(['HEADER', 'Message-ID', message_id])[0]
    end
    
    # Mark message with given flag.
    def flag(name)
      mailbox.uid_store(uid, "+FLAGS", [name])
    end
    
    # Unmark message. 
    def unflag(name)
      mailbox.uid_store(uid, "-FLAGS", [name])
    end
    
    # Do commonly used operations on message. 
    def mark(flag)
      case flag
        when :read    then read!
        when :unread  then unread!
        when :deleted then delete!
        when :spam    then spam!
      else
        flag(flag)
      end
    end
    
    # Mark this message as a spam.
    def spam!
      move_to(mailbox.controller.spam)
    end
    
    # Mark as read.
    def read!
      flag(:Seen)
    end
    
    # Mark as unread.
    def unread!
      unflag(:Seen)
    end
    
    # Mark message with star.
    def star!
      flag('[Google Mail]/Starred')
    end
    
    # Remove message from list of starred.
    def unstar!
      unflag('[Google Mail]/Starred')
    end
    
    # Move to trash.
    def delete!
      mailbox.messages.delete(uid)
      flag(:deleted)
      move_to(mailbox.controller.trash) unless mailbox == mailbox.controller.trash
    end
    
    # Archive this message.
    def archive!
      move_to(mailbox.controller.all_mail)
    end
    
    # Move to given box and delete from others.
    def move_to(name, from=nil)
      label(name, from)
      delete! if mailbox == mailbox.controller.trash
    end
    alias :move :move_to
    
    # Move message to given and delete from others. When given mailbox doesn't
    # exist then it will be automaticaly created.
    def move_to!(name, from=nil)
      label!(name, from) && delete!
    end
    alias :move! :move_to!
    
    # Mark this message with given label. When given label doesn't exist then
    # it will raise <tt>NoLabelError</tt>.
    #
    # See also <tt>Gmail::Message#label!</tt>.
    def label(name, from=nil)
      mailbox.switch_to_mailbox(Net::IMAP.encode_utf7(from.to_s || mailbox.name)) { mailbox.controller.uid_copy(uid, Net::IMAP.encode_utf7(name)) }
    rescue Net::IMAP::NoResponseError
      raise NoLabelError, "Label '#{name}' doesn't exist!"
    end
    
    # Mark this message with given label. When given label doesn't exist then
    # it will be automaticaly created.
    #
    # See also <tt>Gmail::Message#label</tt>.
    def label!(name, from=nil)
      label(name, from)
    rescue NoLabelError
      name = Mailbox.new(mailbox.controller, name).to_s
      label(name, from)
    end
    alias :add_label :label!
    alias :add_label! :label!
    
    # Remove given label from this message. 
    def remove_label!(name)
      move_to(mailbox.controller.all_mail, name)
    end
    alias :delete_label! :remove_label!
    
    def inspect
      "#<Gmail::Message#{'0x%04x' % (object_id << 1)} mailbox=#{@mailbox.external_name}#{' uid='+@uid.to_s if @uid}#{' message_id='+@message_id.to_s if @message_id}>"
    end
    
    def method_missing(meth, *args, &block)
      # Delegate rest directly to the message.
      if envelope.respond_to?(meth)
        envelope.send(meth, *args, &block)
      elsif message.respond_to?(meth)
        message.send(meth, *args, &block)
      else
        super(meth, *args, &block)
      end
    end
    
    def respond_to?(meth, *args, &block)
      if envelope.respond_to?(meth)
        return true
      elsif message.respond_to?(meth)
        return true
      else
        super(meth, *args, &block)
      end
    end
    
    def envelope
      @envelope ||= mailbox.controller.switch_to_mailbox(mailbox) {
        mailbox.controller.uid_fetch(uid, "ENVELOPE")[0].attr["ENVELOPE"]
      }
    end
    
    def message
      @message ||= Mail.new(mailbox.controller.switch_to_mailbox(mailbox.name) { 
        mailbox.controller.uid_fetch(uid, "RFC822")[0].attr["RFC822"] # RFC822
      })
    end
    alias_method :raw_message, :message
  end # Message
end # Gmail
