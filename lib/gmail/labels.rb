module Gmail
  class Labels
    include Enumerable
    attr_reader :connection
    alias :conn :connection
     
    def initialize(connection)
      @connection = connection
    end
    
    # Get list of all defined labels.
    def all(conn)
      @list = conn.list("", "%")
      @list += conn.list("[Gmail]/", "%") unless conn.list("[Gmail]/", "%") == nil
      @list.inject([]) do |labels,label|
        label[:name].each_line {|l| labels << Net::IMAP.decode_utf7(l) }
        labels 
      end
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
  end # Labels
end # Gmail
