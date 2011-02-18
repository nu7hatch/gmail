module Gmail
  class Connection
    # GMail IMAP defaults
    GMAIL_IMAP_HOST = 'imap.gmail.com'
    GMAIL_IMAP_PORT = 993
    
    # GMail SMTP defaults
    GMAIL_SMTP_HOST = "smtp.gmail.com"
    GMAIL_SMTP_PORT = 587
    
    attr_reader :username, :options, :password, :authentication
    def initialize(username, options = {})
      @username = username =~ /@/ ? username : "#{username}@gmail.com"
      @options = options
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
    
    # Return internal IMAP object. Login automaticaly to specified account if necessary.
    def imap
      login and at_exit { logout } unless logged_in?
      @imap
    end
    
    # Login to specified account.
    def login(*args)
      raise NotImplementedError, "The `#{self.class.name}#login` method is not implemented."
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
    
    # Return +true+ when you are logged in to specified account.
    def logged_in?
      return @logged_in
    end
    
    def mail_domain
      username.split('@')[0]
    end
    
    def smtp_settings
      [:smtp, {
        :address => GMAIL_SMTP_HOST,
        :port => GMAIL_SMTP_PORT,
        :domain => mail_domain,
        :user_name => username,
        :password => password,
        :authentication => authentication,
        :enable_starttls_auto => true
      }]
    end
  end # Connection
end # Gmail