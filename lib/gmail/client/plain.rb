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
        if raise_errors
          message = "Couldn't login to given GMail account: #{username}"
          message += " (#{e.response.data.text.strip})"
          raise(AuthorizationError.new(e.response), message, e.backtrace)
        end
      end
    end # Plain

    register :plain, Plain
  end # Client
end # Gmail
