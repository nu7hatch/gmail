require 'net/imap'
require 'date'
require 'time'

module Gmail
  autoload :Labels, "gmail/labels"

  class Client
    # Raised when connection with GMail IMAP service couldn't be established. 
    class ConnectionError < SocketError; end
    # Raised when given username or password are invalid.
    class AuthorizationError < Net::IMAP::NoResponseError; end
  
    GMAIL_IMAP_HOST = 'imap.gmail.com'
    GMAIL_IMAP_PORT = 993
  
    attr_reader :username
    attr_reader :password
    attr_reader :options
  
    def initialize(username, password, options={})
      defaults  = { :raise_errors => true }
      @username = google_username(username)
      @password = password
      @options  = defaults.merge(options)
    end
    
    # Connect to gmail service. 
    def connect
      @imap = Net::IMAP.new(GMAIL_IMAP_HOST, GMAIL_IMAP_PORT, true, nil, false)
    rescue SocketError
      options[:raise_errors] and raise ConnectionError, "Couldn't establish connection with GMail IMAP service"
    end
    
    # Return current connection. Log in automaticaly to specified account if 
    # it is necessary.
    def connection
      login and at_exit { logout } unless logged_in?
      @imap
    end
    alias :conn :connection
    
    # Login to specified account.
    def login
      @imap and @logged_in = (login = @imap.login(username, password)) && login.name == 'OK'
    rescue Net::IMAP::NoResponseError
      options[:raise_errors] and raise AuthorizationError, "Couldn't login to given GMail account: #{username}"
    end
    alias :sign_in :login
    
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
    
    def google_username(username)
      username =~ /@/ ? username : "#{username}@gmail.com"
    end
  end # Client
end # Gmail

=begin
class Gmail
  VERSION = '0.0.9'

  class NoLabel < RuntimeError; end

  ##################################
  #  Gmail.new(username, password)
  ##################################
  def initialize(username, password)
    # This is to hide the username and password, not like it REALLY needs hiding, but ... you know.
    # Could be helpful when demoing the gem in irb, these bits won't show up that way.
    class << self
      class << self
        attr_accessor :username, :password
      end
    end
    meta.username = username =~ /@/ ? username : username + '@gmail.com'
    meta.password = password
    @imap = Net::IMAP.new('imap.gmail.com',993,true,nil,false)
    if block_given?
      login # This is here intentionally. Normally, we get auto logged-in when first needed.
      yield self
      logout
    end
  end

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
  
  def create_label(name)
    imap.create(name)
  end

  # List the available labels
  def labels
    (imap.list("", "%") + imap.list("[Gmail]/", "%")).inject([]) { |labels,label|
      label[:name].each_line { |l| labels << l }; labels }
  end

  # gmail.label(name)
  def label(name)
    mailboxes[name] ||= Mailbox.new(self, mailbox)
  end
  alias :mailbox :label

  ###########################
  #  MAKING EMAILS
  # 
  #  gmail.generate_message do
  #    ...inside Mail context...
  #  end
  # 
  #  gmail.deliver do ... end
  # 
  #  mail = Mail.new...
  #  gmail.deliver!(mail)
  ###########################
  def generate_message(&block)
    require 'net/smtp'
    require 'smtp_tls'
    require 'mail'
    mail = Mail.new(&block)
    mail.delivery_method(*smtp_settings)
    mail
  end

  def deliver(mail=nil, &block)
    require 'net/smtp'
    require 'smtp_tls'
    require 'mail'
    mail = Mail.new(&block) if block_given?
    mail.delivery_method(*smtp_settings)
    mail.from = meta.username unless mail.from
    mail.deliver!
  end
  
  ###########################
  #  LOGIN
  ###########################
  def login
    res = @imap.login(meta.username, meta.password)
    @logged_in = true if res && res.name == 'OK'
  end
  def logged_in?
    !!@logged_in
  end
  # Log out of gmail
  def logout
    if logged_in?
      res = @imap.logout
    end
  ensure
    @logged_in = false
  end

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

  ###########################
  #  Other...
  ###########################
  def inspect
    "#<Gmail:#{'0x%x' % (object_id << 1)} (#{meta.username}) #{'dis' if !logged_in?}connected>"
  end
  
  # Accessor for @imap, but ensures that it's logged in first.
  def imap
    unless logged_in?
      login
      at_exit { logout } # Set up auto-logout for later.
    end
    @imap
  end

  private
    def mailboxes
      @mailboxes ||= {}
    end
    def mailbox_stack
      @mailbox_stack ||= []
    end
    def meta
      class << self; self end
    end
    def domain
      meta.username.split('@')[0]
    end
    def smtp_settings
      [:smtp, {:address => "smtp.gmail.com",
      :port => 587,
      :domain => domain,
      :user_name => meta.username,
      :password => meta.password,
      :authentication => 'plain',
      :enable_starttls_auto => true}]
    end
end

require 'gmail/mailbox'
require 'gmail/message'
=end
