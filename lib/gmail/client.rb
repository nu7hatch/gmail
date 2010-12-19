module Gmail
  module Client
    # Raised when connection with GMail IMAP service couldn't be established. 
    class ConnectionError < SocketError; end
    # Raised when given username or password are invalid.
    class AuthorizationError < Net::IMAP::NoResponseError; end
    # Raised when delivered email is invalid. 
    class DeliveryError < ArgumentError; end
    
    autoload :Base,   'gmail/client/base'
    autoload :IMAP,   'gmail/client/imap'
    autoload :XOAuth, 'gmail/client/xoauth'

    def self.new_imap(*args)
      Gmail::Client::IMAP.new(*args)
    end

    def self.new_xoauth(*args)
      Gmail::Client::XOAuth.new(*args)
    end
  end # Client
end # Gmail
