module Gmail
  class Version #:nodoc:
    MAJOR  = 0
    MINOR  = 3
    PATCH  = 3
    STRING = [MINOR, MAJOR, PATCH].join('.')
  end # Version
  
  def self.version # :nodoc:
    Version::STRING
  end 
end # Gmail
