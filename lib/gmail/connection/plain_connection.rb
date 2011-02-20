module Gmail
  class PlainConnection < Connection
    def initialize(username, password, options={})
      @password = password
      super(username, options)
    end
    
    # Login to specified account.
    def login(raise_errors = false)
      return if @imap.nil?
      
      @logged_in = @imap.login(username, password).name == 'OK'
    rescue Net::IMAP::NoResponseError => e
      raise_errors and raise Gmail::Client::AuthorizationError.new(e.response,
          "Couldn't login to given Gmail account: #{username}")
    end
  end # PlainConnection
end # Gmail