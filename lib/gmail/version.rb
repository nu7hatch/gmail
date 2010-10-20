module Gmail
  class Version #:nodoc:
    STRING = File.open(File.join(File.dirname(__FILE__), "../../VERSION")).read.strip
    MAJOR  = STRING.split(".")[0]
    MINOR  = STRING.split(".")[1]
    TINY   = STRING.split(".")[2]
  end # Version
  
  def self.version # :nodoc:
    Version::STRING
  end 
end # Gmail
