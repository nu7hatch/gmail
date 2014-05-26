module Gmail
  class Labels
    include Enumerable
    attr_reader :connection
    alias :conn :connection
     
    def initialize(connection)
      @connection = connection
    end
    
    # Get list of all defined labels.
    def all
      @list = []
      
      ## check each item in list for subfolders
      conn.list("", "%").each {|l| sublabels_or_label(l)}
      
      @list.inject([]) do |labels,label|
        label[:name].each_line {|l| labels << Net::IMAP.decode_utf7(l) }
        labels 
      end
    end
    alias :list :all
    alias :to_a :all

    def sublabels_or_label(label)
      if label.attr.include? :Hasnochildren
        @list << label
      else
        @list << label
        conn.list("#{label.name}/", "%").each {|l| sublabels_or_label(l)}
      end
    end
    
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
      !!conn.create(Net::IMAP.encode_utf7(label)) rescue false
    end
    alias :new :create
    alias :add :create
    
    # Deletes given label from your account. 
    def delete(label)
      !!conn.delete(Net::IMAP.encode_utf7(label)) rescue false
    end
    alias :remove :delete
    
    def inspect
      "#<Gmail::Labels#{'0x%04x' % (object_id << 1)}>"
    end

    # Localizes a specific label flag into a label name

    # Accepts standard mailbox flags returned by LIST's special-use extension:
    # :Inbox, :All, :Drafts, :Sent, :Trash, :Important, :Junk, :Flagged
    # and their string equivalents. Capitalization agnostic.
    def localize(label)
      type = label.to_sym.capitalize
      if [:All, :Drafts, :Sent, :Trash, :Important, :Junk, :Flagged].include? type
        @mailboxes ||= connection.list("", "*")
        @mailboxes.select {|box| box.attr.include? type }.collect(&:name).compact.uniq.first
      elsif type == :Inbox
        'INBOX'
      else
        label
      end
    end
  end # Labels
end # Gmail
