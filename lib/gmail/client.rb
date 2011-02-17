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
      raise AgumentError, 'wrong number of arguments' if args.length < 2
      
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
    
    %w[login login! connect connect! logout logged_in? username password].each do |method|
      define_method method do |*args|
        @connection.send(method, *args)
      end
    end
    
    # Return a mailbox controller object, which helps you with managing Gmail labels or mailboxes.
    # See <tt>Gmail::MailboxController</tt> for details.
    def mailbox_controller
      @mailbox_controller ||= MailboxController.new(connection.imap)
    end
    
    # Return mailbox object for given name.
    %w[mailbox mailbox!].each do |method|
      define_method(method) do |*args|
        mailbox_controller.send(method, *args)
      end
    end
    
    def inspect
      "#<Gmail::Client#{'0x%04x' % (object_id << 1)} (#{username}) #{'dis' if !logged_in?}connected>"
    end
  end # Client
end # Gmail
