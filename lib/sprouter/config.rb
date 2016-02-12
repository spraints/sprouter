require_relative "ping_check"

module Sprouter
  class Config
    def initialize(options)
      @options = options || {}
    end

    attr_reader :options

    # Domain names of sites that should always go over the fast link.
    def turbo_sites
      deep_values("turbo_sites")
    end

    # IP addresses of local machines that should always get to use the fast link.
    def turbo_hosts
      deep_values("turbo_hosts")
    end

    # IP addresses of local machines that should always get use the fast link if the slow link is particularly bad.
    def preferred_hosts
      deep_values("preferred_hosts")
    end

    # Should preferred_hosts stop being turbo_hosts?
    def go_slower
      ping_check "go_slower"
    end

    # Should preferred_hosts start being turbo_hosts?
    def go_faster
      ping_check "go_faster"
    end

    private

    def ping_check(key)
      config = options["config"] || {}
      Sprouter::PingCheck.build(config[key])
    end

    def deep_values(key)
      result = []
      explore = [ options[key] ]
      while explore.any?
        case obj = explore.shift
        when Array
          result += obj
        when Hash
          explore += obj.values
        end
      end
      result
    end
  end
end
