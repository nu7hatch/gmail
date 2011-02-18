require 'thread'

module Gmail
  class MailboxController
    include Enumerable
    
    attr_reader :client
    def initialize(client)
      @client = client
      @mailbox_mutex = Mutex.new
    end
    
    # Get list of all defined labels.
    def all
      labels = client.imap.list("", "%") # search first level labels.
      gmail_mailboxes = labels.select {|l| l.attr.include?(:Haschildren)}
      gmail_mailboxes.each {|l| labels += client.imap.list("#{l.name}#{l.delim}", "%").to_a}
      
      labels.map {|l| Net::IMAP.decode_utf7(l.name)}
    end
    alias :list :all
    alias :to_a :all
    
    def each(*args, &block)
      all.each(*args, &block)
    end
    
    # Returns +true+ when given label defined. 
    def exists?(label)
      all.include?(label)
    end
    alias :exist? :exists?
    
    # Creates given label in your account.
    def create(label)
      !!client.imap.create(Net::IMAP.encode_utf7(label)) rescue false
    end
    alias :add :create
    
    # Deletes given label from your account. 
    def delete(label)
      !!client.imap.delete(Net::IMAP.encode_utf7(label)) rescue false
    end
    alias :remove :delete
    
    # Cached mailboxes.
    def mailboxes
      @mailboxes ||= {}
    end
    
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