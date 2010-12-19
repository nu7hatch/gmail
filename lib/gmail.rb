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
  autoload :Labels,  "gmail/labels"
  autoload :Mailbox, "gmail/mailbox"
  autoload :Message, "gmail/message"

  class << self

    # Creates new Gmail connection using given authorization options.
    #
    # ==== Examples
    #
    #   Gmail.new(:plain, "foo@gmail.com", "password")
    #   Gmail.new(:xoauth, "foo@gmail.com", 
    #     :consumer_key => "",
    #     :consumer_secret => "",
    #     :token => "",
    #     :secret => "")
    #
    # To use plain authentication mehod you can also call:
    #
    #   Gmail.new("foo@gmail.com", "password")
    #
    # You can also use block-style call:
    #
    #   Gmail.new("foo@gmail.com", "password") do |client|
    #     # ...
    #   end
    #
    def new(*args, &block)
      client = connect_with_proper_client(*args)
      client.connect and client.login
      perform_block(client, &block)
    end
    alias :connect :new

    def new!(*args, &block)
      client = connect_with_proper_client(*args)
      client.connect! and client.login!
      perform_block(client, &block)
    end
    alias :connect! :new!
    
    protected

    def connect_with_proper_client(*args)
      if args.first.is_a?(Symbol)        
        login_method = args.shift  
      else
        login_method ||= :plain
      end

      Client.send("new_#{login_method}", *args)
    end

    def perform_block(client, &block)
      if block_given?
        yield client
        client.logout
      end
      client
    end

  end # << self
end # Gmail
