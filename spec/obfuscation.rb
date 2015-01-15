require 'base64'

# Lightweight obfuscation wrapper used to obfuscate account.yml file.
#
# CAUTION; this is not intended to be a robust security mechanism. It is simple
# obfuscation (security through obscurity). There's no strong reason why we couldn't
# store the credentials in clear text, but just taking an extra step to prevent trouble.

module Spec

  module Obfuscation

    def encrypt(data)
      rot13(Base64.encode64(data))
    end

    def decrypt(data)
      Base64.decode64(rot13(data))
    end

    def rot13(data)
      data.tr!("A-Za-z", "N-ZA-Mn-za-m")
    end

    def encrypt_file(file)
      data = read_if_exist!(file)
      begin
        File.open("#{file}.obfus", 'w') { |file| file.write(encrypt(data)) }
      rescue Exception => e
        raise "Unable to encrypt #{file}"
      end
    end

    def decrypt_file(file)
      data = read_if_exist!(file)
      begin
        return YAML::load(decrypt(data))
      rescue Exception => e
        raise "Unable to decrypt #{file}"
      end
    end

    def read_if_exist!(file)
      if File.exist?(file)
        IO.read(file)
      else
        raise "File not found #{file}"
      end
    end

    extend self

  end
end
