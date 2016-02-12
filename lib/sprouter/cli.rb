require "logger"

require_relative "adjust"
require_relative "config"
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
        while ARGV.any?
          case arg = ARGV.shift
          when "--test", "-t"
            options[:pf] = PF::Test.new
          else
            options[:config] = Config.new(YAML.load(File.read(arg)))
          end
        end
        if options[:config]
          Adjust.new(options).run!
        else
          usage
        end

      else
        usage
      end
    end

    def self.usage
      puts "Usage: sprouter status"
      puts "Usage: sprouter adjust [--test] config.yaml"
      exit 1
    end
  end
end
