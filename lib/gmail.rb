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
