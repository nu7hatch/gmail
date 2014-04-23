# Taken from https://github.com/oxos/gmail-oauth-thread-stats/blob/master/gmail_imap_extensions_compatibility.rb

module GmailImapExtensions

  def self.patch_net_imap_response_parser(klass = Net::IMAP::ResponseParser)
    klass.class_eval do
      def msg_att
        match(Net::IMAP::ResponseParser::T_LPAR)
        attr = {}
        while true
          token = lookahead
          case token.symbol
          when Net::IMAP::ResponseParser::T_RPAR
            shift_token
            break
          when Net::IMAP::ResponseParser::T_SPACE
            shift_token
            token = lookahead
          end
          case token.value
          when /\A(?:ENVELOPE)\z/ni
            name, val = envelope_data
          when /\A(?:FLAGS)\z/ni
            name, val = flags_data
          when /\A(?:INTERNALDATE)\z/ni
            name, val = internaldate_data
          when /\A(?:RFC822(?:\.HEADER|\.TEXT)?)\z/ni
            name, val = rfc822_text
          when /\A(?:RFC822\.SIZE)\z/ni
            name, val = rfc822_size
          when /\A(?:BODY(?:STRUCTURE)?)\z/ni
            name, val = body_data
          when /\A(?:UID)\z/ni
            name, val = uid_data
      
          # Gmail extension additions.
          # Cargo-Cult code warning: # I have no idea why the regexp - just copying a pattern
          when /\A(?:X-GM-LABELS)\z/ni
            name, val = flags_data
          when /\A(?:X-GM-MSGID)\z/ni 
            name, val = uid_data
          when /\A(?:X-GM-THRID)\z/ni 
            name, val = uid_data
          else
            parse_error("unknown attribute `%s'", token.value)
          end
          attr[name] = val
        end
        return attr
      end
    end
  end

end