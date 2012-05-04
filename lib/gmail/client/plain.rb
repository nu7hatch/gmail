module Gmail
  module Client
    class Plain < Base
      attr_reader :password
      
      def initialize(username, password, options={})
        @password = password
        super(username, options)
      end

      def login(raise_errors=false)
        @imap and @logged_in = (login = @imap.login(username, password)) && login.name == 'OK'
      rescue Net::IMAP::NoResponseError => e
        raise_errors and raise AuthorizationError.new(e.response), "Couldn't login to given GMail account: #{username}", e.backtrace
      end
    end # Plain

    register :plain, Plain
  end # Client
end # Gmail
