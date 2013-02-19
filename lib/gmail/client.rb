module Gmail
  module Client
    # Raised when connection with GMail IMAP service couldn't be established. 
    class ConnectionError < SocketError; end
    # Raised when given username or password are invalid.
    class AuthorizationError < Net::IMAP::NoResponseError; end
    # Raised when delivered email is invalid. 
    class DeliveryError < ArgumentError; end
    # Raised when given client is not registered
    class UnknownClient < ArgumentError; end

    def self.register(name, klass)
      @clients ||= {}
      @clients[name] = klass
    end

    def self.new(name, *args)
      if client = @clients[name]
        client.new(*args)
      else
        raise UnknownClient, "No such client: #{name}" 
      end
    end

    require 'gmail/client/imap_extensions'
    require 'gmail/client/base'
    require 'gmail/client/plain'
    require 'gmail/client/xoauth'
    require 'gmail/client/xoauth2'
  end # Client
end # Gmail
