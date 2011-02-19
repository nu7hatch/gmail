require 'thread'

module Gmail
  class MailboxController
    include Enumerable
    
    attr_reader :client
    def initialize(client)
      @client = client
      @mailbox_mutex = Mutex.new
      @mailboxes = {}
      load_mailboxes
    end
    
    # Array of first level mailboxes.
    def mailboxes
      @mailboxes.values
    end
    
    # Array of all mailboxes.
    def all
      mailboxes.inject([]) do |list, mailbox|
        (list << mailbox) + mailbox.descendants
      end
    end
    
    def each(*args, &block)
      all.each(*args, &block)
    end
    
    # Return +true+ when given mailbox defined.
    def exist?(name)
      not all.detect {|mailbox| mailbox.name == name or mailbox.imap_path == name}.nil?
    end
    alias :exists? :exist?
    
    # Create mailbox with given path in your account.
    def create(path)
      client.imap.create(Net::IMAP.encode_utf7(path))
      load_mailboxes
      return true
    rescue
      return false
    end
    alias :add :create
    
    # Delete mailbox with given imap path from your account.
    def delete(path)
      client.imap.delete(Net::IMAP.encode_utf7(path))
      deleted = @mailboxes.delete(path)
      deleted.each_descendant {|d| @mailboxes.delete(d.imap_path)}
      return true
    rescue
      return false
    end
    alias :remove :delete
    
    # Returns a mailbox object for the given name.
    # Creates it if not exists.
    def mailbox(name="INBOX")
      create(name)
      Mailbox.new(client.imap, name)
    end
    
    # This version will raise a error if the given mailbox name not exists.
    def mailbox!(name="INBOX")
      raise KeyError, "mailbox #{name} not found" unless exist?(name)
      Mailbox.new(client.imap, name)
    end
    
    # Switch to a given mailbox.
    def switch_to_mailbox(name, &block)
      @mailbox_mutex.synchronize do
        mailbox = (mailboxes[name] ||= Mailbox.new(self, name))
        _switch_to_mailbox(name) if @current_mailbox != name
        
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
    
    %w[uid_search expunge].each do |method|
      define_method(method) do |*args|
        client.imap.send(method, *args)
      end
    end
    
    def inspect
      "#<Gmail::MailboxController#{'0x%04x' % (object_id << 1)}>"
    end
    
    def load_mailboxes(mailbox=nil)
      mailboxes = {}
      path = mailbox.nil? ? "" : (mailbox.imap_path + mailbox.delim)
        
      client.imap.list(Net::IMAP.encode_utf7(path), "%").to_a.each do |m|
        mailboxes[Net::IMAP.decode_utf7(m.name)] = Mailbox.new(self, m.name, m.delim, mailbox)
      end
      
      @mailboxes.merge!(mailboxes)
      mailboxes
    end
    
    private
    
    def _switch_to_mailbox(mailbox)
      client.imap.select(Net::IMAP.encode_utf7(mailbox)) if mailbox
      @current_mailbox = mailbox
    end
    
    def mailbox_stack
      @mailbox_stack ||= []
    end
  end # MailboxController
end # Gmail