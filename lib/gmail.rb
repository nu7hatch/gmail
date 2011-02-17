require 'net/imap'
require 'net/smtp'
require 'mail'
require 'date'
require 'time'

if RUBY_VERSION < "1.8.7"
  require "smtp_tls"
end

class Object
  def to_imap_date
    Date.parse(to_s).strftime("%d-%B-%Y")
  end
end

module Gmail
  autoload :Version, "gmail/version"
  autoload :Client,  "gmail/client"
  # autoload :Labels,  "gmail/labels"
  # autoload :Mailbox, "gmail/mailbox"
  # autoload :Message, "gmail/message"
  
  class << self
    
    # Creates new Gmail client using given authorization information.
    #
    # ==== Examples
    #
    #   Gmail.new("foo@gmail.com", "password")
    #   Gmail.connect("foo@gmail.com", :xoauth => { :consumer_key => "",
    #       :consumer_secret => "",
    #       :token => "",
    #       :secret => "" })
    #
    # You can also use block-style call:
    #
    #   Gmail.new("foo@gmail.com", "password") do |client|
    #     # ...
    #   end
    #
    def new(*args, &block)
      client = Client.new(*args)
      perform_block(client, &block)
    end
    
    # Creates new Gmail client and login using given authorization infomation.
    def connect(*args, &block)
      client = Client.new(*args)
      client.login()
      perform_block(client, &block)
    end
    
    # This version of connect will raise error on failure...
    def connect!(*args, &block)
      client = Client.new(*args)
      client.login!()
      perform_block(client, &block)
    end
    
    protected
    
    def perform_block(client, &block)
      if block_given?
        yield client
        client.logout
      end
      client
    end
  end # << self
end # Gmail
