module Sprouter
  class CLI
    def self.run!
      command = ARGV.shift
      case command
      when "status"
        require_relative "status"
        Status.run! *ARGV
      when "adjust"
        require_relative "adjust"
        Adjust.run! *ARGV
      else
        puts "Usage: sprouter status"
        puts "Usage: sprouter adjust CONFIGFILE"
        exit 1
      end
    end
  end
end
