require 'gmail_xoauth'

module Gmail
  class XOAuthConnection < Connection
    def initialize(username, options={})
      @password = options.delete(:xoauth)
      @authentication = :xoauth
      super(username, options)
    end
    
    
    
    # Login to specified account.
    def login(raise_errors = false)
      return if @imap.nil?
      
      login = @imap.authenticate('XOAUTH', username,
                                  :consumer_key    => password[:consumer_key],
                                  :consumer_secret => password[:consumer_secret],
                                  :token           => password[:token],
                                  :token_secret    => password[:token_secret])
      @logged_in = login.name == 'OK'
    rescue Net::IMAP::NoResponseError => e
      raise_errors and raise AuthorizationError.new(e.response, "Couldn't login to given Gmail account: #{username}")
    end
  end # XOAuthConnection
end # Gmail