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
    def new(username, password, options={}, &block)
      client = Client.new(username, password, options)
      client.connect and client.login
      if block_given?
        yield client
        client.logout
      end
      client
    end
    alias :connect :new
    
    def new!(username, password, options={}, &block)
      client = Client.new(username, password, options)
      client.connect! and client.login!
      if block_given?
        yield client
        client.logout
      end
      client
    end
    alias :connect! :new!
  end # << self
end # Gmail
