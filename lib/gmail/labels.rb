module Gmail
  class Labels
    include Enumerable
    
    attr_reader :imap
    def initialize(imap)
      @imap = imap
    end
    
    # Get list of all defined labels.
    def all
      labels = imap.list("", "%") # search first level labels.
      gmail_mailboxes = labels.select {|l| l.attr.include?(:Haschildren)}
      gmail_mailboxes.each {|l| labels += imap.list("#{l.name}#{l.delim}", "%").to_a}
      
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
      !!imap.create(Net::IMAP.encode_utf7(label)) rescue false
    end
    alias :add :create
    
    # Deletes given label from your account. 
    def delete(label)
      !!imap.delete(Net::IMAP.encode_utf7(label)) rescue false
    end
    alias :remove :delete
    
    # Returns a mailbox object for the given name.
    # Creates it if not exists.
    def mailbox(name="INBOX")
      create(name)
      Mailbox.new(imap, name)
    end
    
    # This version will raise a error if the given mailbox name not exists.
    def mailbox!(name="INBOX")
      raise KeyError, "mailbox #{name} not found" unless exist?(name)
      Mailbox.new(imap, name)
    end
    
    def inspect
      "#<Gmail::Labels#{'0x%04x' % (object_id << 1)}>"
    end
  end # Labels
end # Gmail