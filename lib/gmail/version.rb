module Gmail
  class Version #:nodoc:
    MAJOR  = 0
    MINOR  = 4
    PATCH  = 0
    EXTRA  = 'brewster'
    STRING = [MAJOR, MINOR, PATCH, EXTRA].join('.')
  end # Version

  def self.version # :nodoc:
    Version::STRING
  end
end # Gmail
