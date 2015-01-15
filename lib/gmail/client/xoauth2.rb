require 'gmail_xoauth'

module Gmail
  module Client
    class XOAuth2 < Base
      attr_reader :token

      def initialize(username, token)
        @token = token

        super(username, {})
      end

      def login(raise_errors=false)
        @imap and @logged_in = (login = @imap.authenticate('XOAUTH2', username, token)) && login.name == 'OK'
      rescue Net::IMAP::NoResponseError => e
        if raise_errors
          message = "Couldn't login to given GMail account: #{username}"
          message += " (#{e.response.data.text.strip})"
          raise(AuthorizationError.new(e.response), message, e.backtrace)
        end
      end

      def smtp_settings
        [:smtp, {
           :address => GMAIL_SMTP_HOST,
           :port => GMAIL_SMTP_PORT,
           :domain => mail_domain,
           :user_name => username,
           :password => token,
           :authentication => :xoauth2,
           :enable_starttls_auto => true
         }]
      end
    end # XOAuth

    register :xoauth2, XOAuth2
  end # Client
end # Gmail
