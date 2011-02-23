module Gmail
  module Client
    # Raised when connection with GMail IMAP service couldn't be established. 
    class ConnectionError < SocketError; end
    # Raised when given username or password are invalid.
    class AuthorizationError < Net::IMAP::NoResponseError
      if RUBY_VERSION >= "1.9.2"
        def initialize(message)
          response = Net::IMAP::ResponseText.new(message)
          super(Net::IMAP::TaggedResponse.new(nil, nil, response, nil))
        end
      end
    end
    # Raised when delivered email is invalid. 
    class DeliveryError < ArgumentError; end
    
    autoload :Base,   'gmail/client/base'
    autoload :Plain,  'gmail/client/plain'
    autoload :XOAuth, 'gmail/client/xoauth'

    def self.new_plain(*args)
      Gmail::Client::Plain.new(*args)
    end

    def self.new_xoauth(*args)
      Gmail::Client::XOAuth.new(*args)
    end
  end # Client
end # Gmail
