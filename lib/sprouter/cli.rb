require "logger"

require_relative "adjust"
require_relative "status"

module Sprouter
  class CLI
    def self.run!
      command = ARGV.shift
      case command
      when "status"
        Status.run!

      when "adjust"
        options = {logger: Logger.new(STDOUT)}
        config_file = nil
        while ARGV.any?
          case arg = ARGV.shift
          when "--test", "-t"
            options[:pf] = PF::Test.new
          else
            config_file = arg
          end
        end
        if config_file
          Adjust.new(options).run!(config_file)
        else
          usage
        end

      else
        usage
      end
    end
  end
end
