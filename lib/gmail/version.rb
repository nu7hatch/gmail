module Gmail
  class Version #:nodoc:
    MAJOR  = 0
    MINOR  = 4
    PATCH  = 0
    STRING = [MAJOR, MINOR, PATCH].join('.')
  end # Version
  
  def self.version # :nodoc:
    Version::STRING
  end 
end # Gmail
