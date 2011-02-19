module Gmail
  class MessageComposer
    attr_reader :client, :smtp_settings
    def initialize(client)
      @client = client
      @smtp_settings = client.smtp_settings
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
    #
    def compose(mail=nil, &block)
      if block_given?
        mail = Mail.new(&block)
      elsif !mail 
        mail = Mail.new
      end 
      
      mail.delivery_method(*smtp_settings)
      mail.from = client.username unless mail.from
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
    #
    def deliver(mail=nil, raise_errors=false, &block)
      mail = compose(mail, &block) if block_given?
      mail.deliver!
    rescue Object => ex
      raise_errors and raise Gmail::Client::DeliveryError, "Couldn't deliver email: #{ex.to_s}"
    end
    
    # This version of deliver will raise error on failure...
    def deliver!(mail=nil, &block)
      deliver(mail, true, &block)
    end
  end # MessageComposer
end # Gmail