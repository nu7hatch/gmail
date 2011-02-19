require 'thread'

module Gmail
  class MailboxController
    include Enumerable
    
    SYSTEM_MAILBOXES_NAME = {
      #:root => '[Gmail], [Google Mail]',
      :inbox => 'INBOX',
      :drafts => 'Drafts, Entw&APw-rfe',
      :importance => 'Important, Wichtig',
      :trash => 'Trash, Bin, Papierkorb',
      :all_mail => 'All Mail, Alle Nachrichten',
      :sent_mail => 'Sent Mail, Gesendet',
      :starred => 'Starred, Markiert',
      :spam => 'Spam'
    }
    
    attr_reader :client, :mailboxes
    def initialize(client)
      @client = client
      @mailbox_mutex = Mutex.new
      @mailboxes = load_mailboxes
      alias_system_mailboxes
      
      self
    end
    
    def delim
      @delim ||= client.imap.list("", "%").first.delim
    rescue
      @delim = "/" 
    end
    
    def labels
      mailboxes.keys
    end
    alias :all_labels :labels
    
    def all_mailboxes
      mailboxes.values
    end
    
    def each(*args, &block)
      mailboxes.values(*args, &block)
    end
    
    # Return +true+ when given mailbox defined.
    def exist?(mailbox)
      mailboxes.key?(mailbox.to_s)
    end
    alias :exists? :exist?
    
    # Create mailbox with given path in your account.
    def create(path)
      client.imap.create(Net::IMAP.encode_utf7(path))
      
      path.split(delim).inject("") do |a, b|
        unless @mailboxes.key?(a+delim+b)
          mailboxes.merge!(load_mailboxes(@mailboxes[a]))
          return true
        end
        a+b
      end
    rescue
      return false
    end
    alias :add :create
    
    # Delete mailbox with given imap path from your account.
    def delete(path)
      # System standard mailboxes cannot be deleted.
      return false if @system_mailboxes.values.map{|m| m.name}.include?(path)
      
      client.imap.delete(Net::IMAP.encode_utf7(path))
      mailboxes.delete_if {|k, v| k.start_with?(path)}
      return true
    rescue
      return false
    end
    alias :remove :delete
    
    # Returns a mailbox object for the given name.
    # Creates it if not exists.
    def mailbox(name="INBOX", raise_error=false)
      return @system_mailboxes[name] if name.is_a?(Symbol)
      return mailboxes[name] if mailboxes.key?(name)
      
      raise_error and raise KeyError, "mailbox not found: #{name}"
      create(name)
      mailboxes[name]
    end
    
    # This version will raise a error if the given mailbox name not exists.
    def mailbox!(name="INBOX")
      mailbox(name, true)
    end
    
    # Switch to a given mailbox.
    def switch_to_mailbox(mailbox, &block)
      @mailbox_mutex.synchronize do
        _switch_to_mailbox(mailbox) if @current_mailbox != mailbox
        
        if block_given?
          mailbox_stack << @current_mailbox
          result = block.arity == 1 ? block.call(mailbox) : block.call
          mailbox_stack.pop
          _switch_to_mailbox(mailbox_stack.last)
          return result
        end
        
        return mailbox
      end
    end
    
    # Make access to methods in client.imap for convenience.
    %w[uid_search uid_store uid_copy uid_fetch expunge].each do |method|
      define_method(method) do |*args|
        client.imap.send(method, *args)
      end
    end
    
    def inspect
      "#<Gmail::MailboxController#{'0x%04x' % (object_id << 1)}>"
    end
    
    # Load the hash which contains all the children mailboxes of the given mailbox.
    def load_mailboxes(mailbox=nil)
      mailboxes = {}
      path = mailbox.nil? ? "" : (mailbox.name + delim)
        
      client.imap.list(Net::IMAP.encode_utf7(path), "%").to_a.each do |m|
        mbox = Mailbox.new(self, Net::IMAP.decode_utf7(m.name))
        mailboxes[mbox.name] ||= mbox
        mailboxes.merge!(load_mailboxes(mbox)) if m.attr.include?(:Haschildren)
      end
      
      mailboxes
    end
    
    # Define methods to access the system mailboxes, e.g #inbox, #all_mail, #spam...
    SYSTEM_MAILBOXES_NAME.each_key do |k|
      define_method(k) do
        @system_mailboxes[k]
      end
    end
    
    private
    
    def alias_system_mailboxes
      @system_mailboxes = {}
      SYSTEM_MAILBOXES_NAME.each do |k, v|
        name = labels.find {|l| v.include?(Net::IMAP.encode_utf7(l.split(delim).last))}.to_s
        @system_mailboxes[k] = mailboxes[name] unless name.empty?
      end
    end
    
    def _switch_to_mailbox(mailbox)
      client.imap.select(Net::IMAP.encode_utf7(mailbox.name)) if mailbox
      @current_mailbox = mailbox
    end
    
    def mailbox_stack
      @mailbox_stack ||= []
    end
  end # MailboxController
end # Gmail