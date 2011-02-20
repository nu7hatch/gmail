module Gmail
  autoload :Connection, 'gmail/connection/connection'
  autoload :PlainConnection, 'gmail/connection/plain_connection'
  autoload :XOAuthConnection, 'gmail/connection/xoauth_connection'
    
  class Client
    # Raised when connection with GMail IMAP service couldn't be established.
    class ConnectionError < SocketError; end
    # Raised when delivered email is invalid.
    class DeliveryError < ArgumentError; end
    
    # Raised when given username or password are invalid.
    class AuthorizationError < StandardError
      # Include the response that caused this error
      def initialize(response, message)
        @response = response
        super message
      end
    end
    
    attr_reader :connection
    def initialize(*args)
      raise ArgumentError, 'wrong number of arguments' if args.length < 2
      
      username = args[0]
      password = args[1].is_a?(String) ? args[1] : ''
      options = args.last.is_a?(Hash) ? args.last : {}
      
      if options.include?(:xoauth) then
        @connection = Gmail::XOAuthConnection.new(username, options)
      else
        @connection = Gmail::PlainConnection.new(username, password, options)
      end
      self
    end
    
    # Connect and login to the given Gmail account.
    def connect
      connection.connect and connection.login
    end
    alias :new :connect
    alias :login :connect
    
    # This will raise error on failure...
    def connect!
      connection.connect! and connection.login!
    end
    alias :new! :connect!
    alias :login! :connect!
    
    # Make access to methods in connection object.
    %w[logout logged_in? imap username password smtp_settings authentication].each do |method|
      define_method(method) do |*args|
        connection.send(method, *args)
      end
    end
    
    # Create and return a mailbox controller object, which helps you with managing Gmail labels or mailboxes.
    # See <tt>Gmail::MailboxController</tt> for details.
    def mailbox_controller
      @mailbox_controller ||= MailboxController.new(self)
    end
    alias :labels :mailbox_controller
    alias :mailboxes :mailbox_controller
    
    # Make access to methods in mailbox controller object.
    %w[mailbox mailbox! all_mailboxes all_labels add create remove delete].each do |method|
      define_method(method) do |*args|
        mailbox_controller.send(method, *args)
      end
    end
    
    # Make access to default mailboxes in mailbox controller object.
    Gmail::MailboxController::SYSTEM_MAILBOXES_NAME.each_key do |k|
      define_method(k) do
        mailbox_controller.send(k)
      end
    end
    
    # Create and return a message composer object, which helps you with composing and deliver messages.
    def message_composer
      @message_composer ||= MessageComposer.new(self)
    end
    
    # Make access to methods in message composer object.
    %w[compose message deliver deliver!].each do |method|
      define_method(method) do |*args, &block|
        message_composer.send(method, *args, &block)
      end
    end
    
    def inspect
      "#<Gmail::Client#{'0x%04x' % (object_id << 1)} (#{username}) #{'dis' if !logged_in?}connected>"
    end
  end # Client
end # Gmail