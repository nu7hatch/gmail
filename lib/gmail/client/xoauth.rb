require 'gmail_xoauth'

module Gmail
  module Client
    class XOAuth < Base
      attr_reader :token
      attr_reader :secret
      attr_reader :consumer_key
      attr_reader :consumer_secret
      attr_reader :two_legged

      def initialize(username, options={})
        @token           = options.delete(:token)
        @secret          = options.delete(:secret)
        @consumer_key    = options.delete(:consumer_key)
        @consumer_secret = options.delete(:consumer_secret)
        @two_legged      = options.delete(:two_legged)

        super(username, options)
      end

      def login(raise_errors=false)
        @imap and @logged_in = (login = @imap.authenticate('XOAUTH', username,
          :consumer_key    => consumer_key,
          :consumer_secret => consumer_secret,
          :token           => token,
          :token_secret    => secret,
          :two_legged      => two_legged
        )) && login.name == 'OK'
      rescue
        raise_errors and raise AuthorizationError, "Couldn't login to given GMail account: #{username}"
      end

      def smtp_settings
        [:smtp, {
           :address => GMAIL_SMTP_HOST,
           :port => GMAIL_SMTP_PORT,
           :domain => mail_domain,
           :user_name => username,
           :password => {
             :consumer_key    => consumer_key,
             :consumer_secret => consumer_secret,
             :token           => token,
             :token_secret    => secret,
             :two_legged      => two_legged
           },
           :authentication => :xoauth,
           :enable_starttls_auto => true
         }]
      end
    end # XOAuth

    register :xoauth, XOAuth
  end # Client
end # Gmail
