# Taken from https://github.com/oxos/gmail-oauth-thread-stats/blob/master/gmail_imap_extensions_compatibility.rb

module GmailImapExtensions

  def self.patch_net_imap_response_parser(klass = Net::IMAP::ResponseParser)
    klass.class_eval do
      def msg_att
        match(T_LPAR)
        attr = {}
        while true
          token = lookahead
          case token.symbol
          when T_RPAR
            shift_token
            break
          when T_SPACE
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
            name, val = x_gm_labels_data
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

      # Based on Net::IMAP#flags_data, but calling x_gm_labels_list to parse labels
      def x_gm_labels_data
        token = match(self.class::T_ATOM)
        name = token.value.upcase
        match(self.class::T_SPACE)
        return name, x_gm_label_list
      end

      # Based on Net::IMAP#flag_list with a modified Regexp
      # Labels are returned as escape-quoted strings
      # We extract the labels using a regexp which extracts any unescaped strings
      def x_gm_label_list
        if @str.index(/\(([^)]*)\)/ni, @pos)
          resp = extract_labels_response

          # We need to manually update the position of the regexp to prevent trip-ups
          @pos += resp.length
          return resp.scan(/"([^"\\]*(?:\\.[^"\\]*)*)"/ni).flatten.collect(&:unescape)
        else
          parse_error("invalid label list")
        end
      end

      # The way Gmail return tokens can cause issues with Net::IMAP's reader,
      # so we need to extract this section manually
      def extract_labels_response
        special, quoted = false, false
        index, paren_count = 0, 0

        # Start parsing response string for the labels section, parentheses inclusive
        labels_header = "X-GM-LABELS ("
        start = @str.index(labels_header) + labels_header.length - 1
        substr = @str[start..-1]
        substr.each_char do |char|
          index += 1
          case char
          when '('
            paren_count += 1 unless quoted
          when ')'
            paren_count -= 1 unless quoted
            break if paren_count == 0
          when '"'
            quoted = !quoted unless special
          end
          special = (char == '\\' && !special)
        end
        substr[0..index]
      end
    end # class_eval

    # Add String#unescape
    add_unescape
  end # PNIRP

  def self.add_unescape(klass = String)
    klass.class_eval do
      # Add a method to string which unescapes special characters
      # We use a simple state machine to ensure that specials are not
      # themselves escaped
      def unescape
        unesc = ''
        special = false
        escapes = { '\\' => '\\',
                    '"'  => '"',
                    'n' => "\n",
                    't' => "\t",
                    'r' => "\r",
                    'f' => "\f",
                    'v' => "\v",
                    '0' => "\0",
                    'a' => "\a"
                  }

        self.each_char do |char|
          if special
            # If in special mode, add in the replaced special char if there's a match
            # Otherwise, add in the backslash and the current character
            unesc << (escapes.keys.include?(char) ? escapes[char] : "\\#{char}")
            special = false
          else
            # Toggle special mode if backslash is detected; otherwise just add character
            if char == '\\'
              special = true
            else
              unesc << char
            end
          end
        end
        unesc
      end
    end
  end
end
