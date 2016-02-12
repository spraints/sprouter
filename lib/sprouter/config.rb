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

    # How bad must the connection be before sending preferred hosts over the fast link?
    #
    # This should be a number between 0.0 and 1.0.
    def pingdrop_threshold
      config.fetch("threshold", 1.0)
    end

    # Where do we look for the pingdrop metric?
    def pingdrop_url
      config.fetch("stat", nil)
    end

    private

    def config
      options["config"] || {}
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
