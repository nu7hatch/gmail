module Gmail
  class Mailbox
    MAILBOX_ALIASES = {
      :all       => ['ALL'],
      :seen      => ['SEEN'],
      :unseen    => ['UNSEEN'],
      :read      => ['SEEN'],
      :unread    => ['UNSEEN'],
      :flagged   => ['FLAGGED'],
      :unflagged => ['UNFLAGGED'],
      :starred   => ['FLAGGED'],
      :unstarred => ['UNFLAGGED'], 
      :deleted   => ['DELETED'],
      :undeleted => ['UNDELETED'],
      :draft     => ['DRAFT'],
      :undrafted => ['UNDRAFT']
    }
    
    attr_reader :controller, :name
    def initialize(controller, name="INBOX")
      @controller = controller
      @name = name
      
      # Add self to controller's list of mailboxes.
      controller.create(name)
      self
    end
    
    def new(*args)
      raise ArgumentError, "wrong number of arguments" if args.length < 1
      return args[0].mailbox!(name) if args[0].exist?(name)
      
      instance = allocate
      instance.send(:initialize, *args)
    end
    
    # Children mailboxes.
    def children
      regexp = Regexp.new("#{Regexp.escape(name + controller.delim)}[^#{Regexp.escape(controller.delim)}]+")
      controller.mailboxes.select {|k, v| regexp.match(k)}.values
    end
    
    # Enumerate for children.
    def each_child(*args, &block)
      children.each(*args, &block)
    end
    
    # All descent mailboxes.
    def descendants
      controller.mailboxes.select {|k, v| k.start_with?(name)}.values
    end
    
    # Enumerate for descendants.
    def each_descendant(*args, &block)
      descendants.each(*args, &block)
    end
    
    # Return list of emails which meets given criteria.
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
    #
    def emails(*args, &block)
      args << :all if args.size.zero?
      
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
        opts[:search]     and search.concat ['BODY', opts[:search]]
        opts[:body]       and search.concat ['BODY', opts[:body]]
        opts[:query]      and search.concat opts[:query]
        
        controller.switch_to_mailbox(self) do
          controller.uid_search(search).collect do |uid|
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
    alias :find :emails
    
    # This is a convenience method that really probably shouldn't need to exist,
    # but it does make code more readable, if seriously all you want is the count
    # of messages.
    #
    # ==== Examples
    #
    #   gmail.inbox.count(:all)
    #   gmail.inbox.count(:unread, :from => "friend@gmail.com")
    #   gmail.mailbox("Test").count(:all, :after => Time.now-(20*24*3600))
    #
    def count(*args)
      emails(*args).size
    end
    
    # This permanently removes messages which are marked as deleted
    def expunge
      controller.switch_to_mailbox(self) { controller.expunge }
    end
    
    # Cached messages.
    def messages
      @messages ||= {}
    end
    
    def uid_store(*args)
      !!controller.switch_to_mailbox(self) { controller.uid_store(*args) }
    end
    
    def inspect
      "#<Gmail::Mailbox#{'0x%04x' % (object_id << 1)} name=#{name}>"
    end
    
    def to_s
      name
    end
    
    MAILBOX_ALIASES.each_key do |mailbox|
      define_method(mailbox) do |*args, &block|
        emails(mailbox, *args, &block)
      end
    end
  end # Mailbox
end # Gmail