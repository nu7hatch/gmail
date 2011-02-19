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
    
    def delim
      @delim ||= client.imap.list("", "%").first.delim
    rescue
      @delim = "/" 
    end
    
    # Array of all mailboxes.
    def mailboxes
      @mailboxes.values
    end
    
    def each(*args, &block)
      @mailboxes.values(*args, &block)
    end
    
    # Return +true+ when given mailbox defined.
    def exist?(name)
      @mailboxes.key?(name)
    end
    alias :exists? :exist?
    
    # Create mailbox with given path in your account.
    def create(path)
      client.imap.create(Net::IMAP.encode_utf7(path))
      
      path.split(delim).inject("") do |a, b|
        unless @mailboxes.key?(a+delim+b)
          @mailboxes[a].children = load_mailboxes(@mailboxes[a])
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
      client.imap.delete(Net::IMAP.encode_utf7(path))
      deleted = @mailboxes.delete(path)
      deleted.parent.children.delete(deleted) unless deleted.parent.nil?
      deleted.each_descendant {|d| @mailboxes.delete(d.imap_path)}
      return true
    rescue
      return false
    end
    alias :remove :delete
    
    # Returns a mailbox object for the given name.
    # Creates it if not exists.
    def mailbox(name="INBOX", raise_error=false)
      return @mailboxes[name] if @mailboxes.key?(name)
      
      raise_error and raise KeyError, "mailbox not found: #{name}"
      create(name)
      @mailboxes[name]
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
      path = mailbox.nil? ? "" : (mailbox.imap_path + delim)
        
      client.imap.list(Net::IMAP.encode_utf7(path), "%").to_a.each do |m|
        mailboxes[Net::IMAP.decode_utf7(m.name)] ||= Mailbox.new(self, Net::IMAP.decode_utf7(m.name), mailbox)
      end
      
      @mailboxes.merge!(mailboxes)
      mailboxes
    end
    
    private
    
    def _switch_to_mailbox(mailbox)
      client.imap.select(Net::IMAP.encode_utf7(mailbox.imap_path)) if mailbox
      @current_mailbox = mailbox
    end
    
    def mailbox_stack
      @mailbox_stack ||= []
    end
  end # MailboxController
end # Gmail