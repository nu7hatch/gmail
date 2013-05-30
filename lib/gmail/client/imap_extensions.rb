# Modified from http://apidock.com/ruby/v1_9_3_125/Net/IMAP/ResponseParser/msg_att
# https://github.com/nu7hatch/gmail/issues/78
class Net::IMAP::ResponseParser
  def msg_att(n = -1)
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
        next
      end
      case token.value
      when /\A(?:ENVELOPE)\z/i
        name, val = envelope_data
      when /\A(?:FLAGS)\z/i
        name, val = flags_data
      when /\A(?:INTERNALDATE)\z/i
        name, val = internaldate_data
      when /\A(?:RFC822(?:\.HEADER|\.TEXT)?)\z/i
        name, val = rfc822_text
      when /\A(?:RFC822\.SIZE)\z/i
        name, val = rfc822_size
      when /\A(?:BODY(?:STRUCTURE)?)\z/i
        name, val = body_data
      when /\A(?:UID)\z/i
        name, val = uid_data
      when /\A(?:X-GM-LABELS)\z/i
        name, val = flags_data
      when /\A(?:X-GM-MSGID)\z/i
        name, val = uid_data
      when /\A(?:X-GM-THRID)\z/i
        name, val = uid_data
      else
        parse_error("unknown attribute `%s' for {%d}", token.value, n)
      end
      attr[name] = val
    end
    return attr
  end
end
