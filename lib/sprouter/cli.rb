module Sprouter
  class CLI
    def self.run!
      command = ARGV.shift
      case command
      when "status"
        require_relative "status"
        Status.run!
      when "adjust"
        require_relative "adjust"
        options = {}
        config_file = nil
        while ARGV.any?
          case arg = ARGV.shift
          when "--test", "-t"
            options[:logger] = Logger.new(STDOUT)
            options[:pf] = PF::Test.new(logger: options[:logger])
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
