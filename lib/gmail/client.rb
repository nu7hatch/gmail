require 'gmail_xoauth'

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
    
    # GMail IMAP defaults
    GMAIL_IMAP_HOST = 'imap.gmail.com'
    GMAIL_IMAP_PORT = 993
    
    # GMail SMTP defaults
    GMAIL_SMTP_HOST = "smtp.gmail.com"
    GMAIL_SMTP_PORT = 587
    
    attr_reader :username, :options, :password, :xoauth
    def initialize(username, password, options = {})
      @username = username =~ /@/ ? username : "#{username}@gmail.com"
      @password = password
      @options = options
      @xoauth = @options.include?(:xoauth) ? @options.delete(:xoauth) : {}
      @logged_in = false
    end
    
    # Connect to gmail service. 
    def connect(raise_errors=false)
      @imap = Net::IMAP.new(GMAIL_IMAP_HOST, GMAIL_IMAP_PORT, true, nil, false)
    rescue SocketError
      raise_errors and raise ConnectionError, "Couldn't establish connection with GMail IMAP service"
    end
    
    # This version of connect will raise error on failure...
    def connect!
      connect(true)
    end
    
    # Login to specified account.
    def login(raise_errors = false)
      return if @imap.nil?
      
      if @xoauth.empty? then
        login = @imap.login(username, password)
        @logged_in = login.name == 'OK'
      else
        login = @imap.authenticate('XOAUTH', username,
                                    :consumer_key    => @xoauth[:consumer_key],
                                    :consumer_secret => @xoauth[:consumer_secret],
                                    :token           => @xoauth[:token],
                                    :token_secret    => @xoauth[:token_secret])
        @logged_in = login.name == 'OK'
      end
    rescue Net::IMAP::NoResponseError => e
      raise_errors and raise AuthorizationError.new(e.response, "Couldn't login to given Gmail account: #{username}")
    end
    
    # This version of login will raise error on failure...
    def login!
      login(true)
    end
    
    # Logout from Gmail service. 
    def logout
      @imap && logged_in? and @imap.logout
    ensure
      @logged_in = false
    end
    
    # Returns +true+ when you are logged in to specified account.
    def logged_in?
      return @logged_in
    end
    
    private
    def mail_domain
      username.split('@')[0]
    end
    
    def smtp_settings
      if @xoauth.empty? then
        [:smtp, {
          :address => GMAIL_SMTP_HOST,
          :port => GMAIL_SMTP_PORT,
          :domain => mail_domain,
          :user_name => username,
          :password => password,
          :authentication => 'plain',
          :enable_starttls_auto => true
        }]
      else
        [:smtp, {
           :address => GMAIL_SMTP_HOST,
           :port => GMAIL_SMTP_PORT,
           :domain => mail_domain,
           :user_name => username,
           :password => secret = {
             :consumer_key    => @xoauth[:consumer_key],
             :consumer_secret => @xoauth[:consumer_secret],
             :token           => @xoauth[:token],
             :token_secret    => @xoauth[:token_secret]
           },
           :authentication => :xoauth,
           :enable_starttls_auto => true
         }]
      end
    end
  end # Client
end # Gmail
