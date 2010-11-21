module Gmail
  class Mailbox
    MAILBOX_ALIASES = {
      :all    => ['ALL'],
      :unseen => ['UNSEEN'],
      :seen   => ['SEEN'],
      :unread => ['UNSEEN'], # not IMAP standard but common usage
      :read   => ['SEEN'], # not IMAP standard but common usage
      :flagged => ['FLAGGED'],
      :unflagged => ['UNFLAGGED'],
      :starred => ['FLAGGED'], # not IMAP standard, but Gmail slang
      :unstarred => ['UNFLAGGED'], # not IMAP standard, but Gmail slang
      :deleted => ['DELETED'],
      :undeleted => ['UNDELETED'],
      :draft => ['DRAFT'],
      :draft => ['UNDRAFT']
      # According to http://mail.google.com/support/bin/answer.py?hl=en&answer=78761, ANSWERED and RECENT are not supported
      # There are more flags, e.g. new which resolves to RECENT UNSEEN and is probably unsupported - need to try.
    }
  
    attr_reader :name

    def initialize(gmail, name="INBOX")
      @name  = name
      @gmail = gmail
    end

    # Returns list of emails which meets given criteria. 
    #
    # ==== Examples
    #
    #   gmail.inbox.emails(:all)
    #   gmail.inbox.emails(:unread, :from => "friend@gmail.com")
    #   gmail.inbox.emails(:all, :after => Time.now-(20*24*3600))
    #   gmail.mailbox("Test").emails(:read)
    #
    #   gmail.mailbox("Test") do |box| 
    #     box.emails(:read)
    #     box.emails(:unread) do |email|
    #       ... do something with each email...
    #     end
    #   end
    def emails(*args, &block)
      args << :all if args.size == 0

      if args.first.is_a?(Symbol) 
        search = MAILBOX_ALIASES[args.shift].dup
        opts = args.first.is_a?(Hash) ? args.first : {}
        
        opts[:after]      and search.concat ['SINCE', opts[:after].to_imap_date]
        opts[:before]     and search.concat ['BEFORE', opts[:before].to_imap_date]
        opts[:on]         and search.concat ['ON', opts[:on].to_imap_date]
        opts[:from]       and search.concat ['FROM', opts[:from]]
        opts[:to]         and search.concat ['TO', opts[:to]]
        opts[:subject]    and search.concat ['SUBJECT', opts[:subject]]
        opts[:label]      and search.concat ['LABEL', opts[:label]]
        opts[:attachment] and search.concat ['HAS', 'attachment']
        opts[:search]     and search.concat [opts[:search]]
        
        @gmail.mailbox(name) do
          @gmail.conn.uid_search(search).collect do |uid| 
            message = (messages[uid] ||= Message.new(self, uid))
            block.call(message) if block_given?
            message
          end
        end
      elsif args.first.is_a?(Hash)
        emails(:all, args.first)
      else
        raise ArgumentError, "Invalid search criteria"
      end
    end
    alias :mails :emails
    alias :search :emails
    alias :find :emails
    alias :filter :emails

    # This is a convenience method that really probably shouldn't need to exist, 
    # but it does make code more readable, if seriously all you want is the count 
    # of messages.
    #
    # ==== Examples
    #
    #   gmail.inbox.count(:all)
    #   gmail.inbox.count(:unread, :from => "friend@gmail.com")
    #   gmail.mailbox("Test").count(:all, :after => Time.now-(20*24*3600))
    def count(*args)
      emails(*args).size
    end

    # This permanently removes messages which are marked as deleted
    def expunge
      @gmail.conn.expunge
    end

    # Cached messages. 
    def messages
      @messages ||= {}
    end
    
    def inspect
      "#<Gmail::Mailbox#{'0x%04x' % (object_id << 1)} name=#{@name}>"
    end

    def to_s
      name
    end
  end # Message
end # Gmail
