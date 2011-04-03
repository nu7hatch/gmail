require 'gmail_xoauth'

module Gmail
  module Client
    class XOAuth < Base
      attr_reader :token
      attr_reader :secret
      attr_reader :consumer_key
      attr_reader :consumer_secret

      def initialize(username, options={})
        @token           = options.delete(:token)
        @secret          = options.delete(:secret)
        @consumer_key    = options.delete(:consumer_key)
        @consumer_secret = options.delete(:consumer_secret)
       
        super(username, options)
      end

      def login(raise_errors=false)
        @imap and @logged_in = (login = @imap.authenticate('XOAUTH', username,
          :consumer_key    => consumer_key,
          :consumer_secret => consumer_secret,
          :token           => token,
          :token_secret    => secret
        )) && login.name == 'OK'
      rescue
        raise_errors and raise AuthorizationError, "Couldn't login to given GMail account: #{username}"        
      end

      def access_token
        consumer_options = {
          :site               => "https://www.google.com",
          :request_token_path => "/accounts/OAuthGetRequestToken",
          :authorize_path     => "/accounts/OAuthAuthorizeToken",
          :access_token_path  => "/accounts/OAuthGetAccessToken"
        }
        consumer = OAuth::Consumer.new(consumer_key, consumer_secret, consumer_options)
        @access_token ||= OAuth::AccessToken.new(consumer, token, secret)
        @access_token
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
             :access_token    => access_token
           },
           :authentication => :xoauth,
           :enable_starttls_auto => true
         }]
      end
    end # XOAuth
  end # Client
end # Gmail
