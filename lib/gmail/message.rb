require 'mime/message'

module Gmail
  class Message
    # Raised when given label doesn't exists.
    class NoLabelError < Exception; end 
  
    attr_reader :uid
    
    def initialize(mailbox, uid)
      @uid     = uid
      @mailbox = mailbox
      @gmail   = mailbox.instance_variable_get("@gmail") if mailbox
    end
    
    ###
    # Returns the email labels. Read more about this extension in the following link:
    #   https://developers.google.com/google-apps/gmail/imap_extensions#access_to_the_gmail_thread_id_x-gm-thrid
    #
    def labels
      fetch_email_data.attr["X-GM-LABELS"]
    end
    
    ###
    # Returns the thread id. Read more about this extension in the following link:
    #   https://developers.google.com/google-apps/gmail/imap_extensions#access_to_the_gmail_thread_id_x-gm-thrid
    #
    def thread_id
      fetch_email_data.attr["X-GM-THRID"]
    end
   
    def uid
      @uid ||= fetch_email_data.attr("UID")
    end
    
    # Mark message with given flag.
    def flag(name)
      !!@gmail.mailbox(@mailbox.name) { @gmail.conn.uid_store(uid, "+FLAGS", [name]) }
    end
    
    # Unmark message. 
    def unflag(name)
      !!@gmail.mailbox(@mailbox.name) { @gmail.conn.uid_store(uid, "-FLAGS", [name]) }
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
      move_to('[Gmail]/Spam')
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
      flag('[Gmail]/Starred')
    end
    
    # Remove message from list of starred.
    def unstar!
      unflag('[Gmail]/Starred')
    end
    
    # Move to trash / bin.
    def delete!
      @mailbox.messages.delete(uid)
      flag(:deleted)

      # For some, it's called "Trash", for others, it's called "Bin". Support both.
      trash =  @gmail.labels.exist?('[Gmail]/Bin') ? '[Gmail]/Bin' : '[Gmail]/Trash'
      move_to(trash) unless %w[[Gmail]/Spam [Gmail]/Bin [Gmail]/Trash].include?(@mailbox.name)
    end

    # Archive this message.
    def archive!
      move_to('[Gmail]/All Mail')
    end
    
    # Move to given box and delete from others.  
    def move_to(name, from=nil)
      label(name, from)
      delete! if !%w[[Gmail]/Bin [Gmail]/Trash].include?(name)
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
      @gmail.mailbox(Net::IMAP.encode_utf7(from || @mailbox.external_name)) { @gmail.conn.uid_copy(uid, Net::IMAP.encode_utf7(name)) }
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
      @gmail.labels.add(Net::IMAP.encode_utf7(name))
      label(name, from)
    end
    alias :add_label :label!
    alias :add_label! :label!
    
    # Remove given label from this message. 
    def remove_label!(name)
      move_to('[Gmail]/All Mail', name)
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
      @envelope ||= @gmail.mailbox(@mailbox.name) {
        fetch_email_data.attr["ENVELOPE"]
      }
    end
    
    def message
      @message ||= Mail.new(@gmail.mailbox(@mailbox.name) { 
        fetch_email_data.attr["RFC822"] # RFC822
      })
    end
    alias_method :raw_message, :message

    protected 
    # Just one request to fetch all the data we need
    def fetch_email_data
      @email_data ||= @gmail.conn.uid_fetch(uid, ["RFC822", 'ENVELOPE', 'X-GM-LABELS', 'X-GM-THRID'])[0]
    end
  end # Message
end # Gmail
