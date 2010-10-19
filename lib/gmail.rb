require 'net/imap'
require 'net/smtp'
require 'mail'

if RUBY_VERSION < "1.8.7"
  require "smtp_tls"
end

module Gmail
  #autoload :Client,  "gmail/client"
  autoload :Labels,  "gmail/labels"
  autoload :Mailbox, "gmail/mailbox"
  autoload :Message, "gmail/message"

  class << self
    def new(username, password, options={}, &block)
      client = Client.new(username, password, options)
      if block_given?
        client.connect
        yield client
        client.logout
      end
    end
    alias :connect :new
    
    def new!(username, password, options={}, &block)
      client = Client.new(username, password, options)
      if block_given?
        client.connect! and client.login!
        yield client
        client.logout
      end
    end
    alias :connect! :new!
  end

  class Client
    # Raised when connection with GMail IMAP service couldn't be established. 
    class ConnectionError < SocketError; end
    # Raised when given username or password are invalid.
    class AuthorizationError < Net::IMAP::NoResponseError; end
    # Raised when delivered email is invalid. 
    class DeliveryError < ArgumentError; end
  
    # GMail IMAP defaults
    GMAIL_IMAP_HOST = 'imap.gmail.com'
    GMAIL_IMAP_PORT = 993
    
    # GMail SMTP defaults
    GMAIL_SMTP_HOST = "smtp.gmail.com"
    GMAIL_SMTP_PORT = 587
  
    attr_reader :username
    attr_reader :password
    attr_reader :options
  
    def initialize(username, password, options={})
      defaults  = {}
      @username = fill_username(username)
      @password = password
      @options  = defaults.merge(options)
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
    
    # Return current connection. Log in automaticaly to specified account if 
    # it is necessary.
    def connection
      login and at_exit { logout } unless logged_in?
      @imap
    end
    alias :conn :connection
    
    # Login to specified account.
    def login(raise_errors=false)
      @imap and @logged_in = (login = @imap.login(username, password)) && login.name == 'OK'
    rescue Net::IMAP::NoResponseError
      raise_errors and raise AuthorizationError, "Couldn't login to given GMail account: #{username}"
    end
    alias :sign_in :login
    
    # This version of login will raise error on failure...
    def login!
      login(true)
    end
    alias :sign_in! :login!
    
    # Returns +true+ when you are logged in to specified account.
    def logged_in?
      !!@logged_in
    end
    alias :signed_in? :logged_in?
    
    # Logout from GMail service. 
    def logout
      @imap && logged_in? and @imap.logout
    ensure
      @logged_in = false
    end
    alias :sign_out :logout
    
    # Return labels object, which helps you with managing your GMail labels.
    # See <tt>Gmail::Labels</tt> for details.
    def labels
      @labels ||= Labels.new(conn)
    end
    
    # Compose new e-mail.
    #
    # ==== Examples
    #   
    #   mail = gmail.compose
    #   mail.from "test@gmail.org"
    #   mail.to "friend@gmail.com"
    #
    # ... or block style:
    #  
    #   mail = gmail.compose do 
    #     from "test@gmail.org"
    #     to "friend@gmail.com"
    #     subject "Hello!"
    #     body "Hello my friend! long time..."
    #   end
    #
    # Now you can deliver your mail:
    #
    #   gmail.deliver(mail)
    def compose(mail=nil, &block)
      if block_given?
        mail = Mail.new(&block)
      elsif !mail 
        mail = Mail.new
      end 
      mail.delivery_method(*smtp_settings)
      mail.from = username unless mail.from
      mail
    end
    alias :message :compose
    
    # Compose (optionaly) and send given email. 
    #
    # ==== Examples
    #
    #   gmail.deliver do 
    #     to "friend@gmail.com"
    #     subject "Hello friend!"
    #     body "Hi! How are you?"
    #   end
    #
    # ... or with already created message:
    #
    #   mail = Mail.new { ... }
    #   gmail.deliver(mail)
    #
    #   mail = gmail.compose { ... }
    #   gmail.deliver(mail) 
    def deliver(mail=nil, raise_errors=false, &block)
      mail = compose(mail, &block) if block_given?
      mail.deliver!
    rescue Object => ex
      raise_errors and raise DeliveryError, "Couldn't deliver email: #{ex.to_s}"
    end
    
    # This version of deliver will raise error on failure...
    def deliver!(mail=nil, &block)
      deliver(mail, true, &block)
    end
    
    def inspect
      "#<Gmail::Client#{'0x%04x' % (object_id << 1)} (#{username}) #{'dis' if !logged_in?}connected>"
    end
    
    def fill_username(username)
      username =~ /@/ ? username : "#{username}@gmail.com"
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
        :authentication => 'plain',
        :enable_starttls_auto => true
      }]
    end
  end # Client
end # Gmail

=begin
class Gmail
  VERSION = '0.0.9'

  class NoLabel < RuntimeError; end

  ###########################
  #  READING EMAILS
  # 
  #  gmail.inbox
  #  gmail.label('News')
  #  
  ###########################

  def inbox
    in_label('inbox')
  end

  # gmail.label(name)
  def label(name)
    mailboxes[name] ||= Mailbox.new(self, mailbox)
  end
  alias :mailbox :label

  def in_mailbox(mailbox, &block)
    if block_given?
      mailbox_stack << mailbox
      unless @selected == mailbox.name
        imap.select(mailbox.name)
        @selected = mailbox.name
      end
      value = block.arity == 1 ? block.call(mailbox) : block.call
      mailbox_stack.pop
      # Select previously selected mailbox if there is one
      if mailbox_stack.last
        imap.select(mailbox_stack.last.name)
        @selected = mailbox.name
      end
      return value
    else
      mailboxes[name] ||= Mailbox.new(self, mailbox)
    end
  end
  alias :in_label :in_mailbox

  private
    def mailboxes
      @mailboxes ||= {}
    end
    def mailbox_stack
      @mailbox_stack ||= []
    end
end

require 'gmail/mailbox'
require 'gmail/message'
=end
