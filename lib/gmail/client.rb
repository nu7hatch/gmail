module Gmail
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
    
    def initialize(*args); @logged_in = false; end
    def logout; @logged_in = false; end
    def logged_in?; return @logged_in; end
    def login
      @logged_in = true
    end
    alias :login! :login 
  end
  # module Client
  #   # Raised when connection with GMail IMAP service couldn't be established. 
  #   class ConnectionError < SocketError; end
  #   # Raised when given username or password are invalid.
  #   class AuthorizationError < Net::IMAP::NoResponseError
  #     # NoResponseError require a Response object to create
  #     def initialize(response, message)
  #       response.data.text = message
  #       super response
  #     end
  #   end
  #   # Raised when delivered email is invalid. 
  #   class DeliveryError < ArgumentError; end
  #   
  #   class Client; end
  #   autoload :Base,   'gmail/client/base'
  #   autoload :Plain,  'gmail/client/plain'
  #   autoload :XOAuth, 'gmail/client/xoauth'
  # 
  #   def self.new_plain(*args)
  #     Gmail::Client::Plain.new(*args)
  #   end
  # 
  #   def self.new_xoauth(*args)
  #     Gmail::Client::XOAuth.new(*args)
  #   end
  # end # Client
end # Gmail
