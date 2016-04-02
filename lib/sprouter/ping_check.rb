require "json"
require "logger"
require "net/http"
require "stringio"
require "uri"

module Sprouter
  class PingCheck
    def self.build(config)
      return Null.new if config.nil? || config.empty?

      options = {}
      options[:stat_url] = config.fetch("stat_url")
      options[:window] = config.fetch("window")
      mode = config.fetch("mode")
      below = config["below"]
      above = config["above"]

      options[:aggregator] =
        case config.fetch("mode")
        when "average"
          Averager.new
        when "all"
          if below
            Max.new
          else
            Min.new
          end
        else
          return Null.new
        end

      options[:comparator] =
        if below
          Below.new(below)
        else
          Above.new(above)
        end

      new(options)
    end

    class Null < PingCheck
      def initialize; end

      def triggered?
        false
      end
    end

    def initialize(aggregator:, comparator:, stat_url:, window:)
      @aggregator = aggregator
      @comparator = comparator
      @stat_url = stat_url
      @window = window
    end

    attr_reader :aggregator, :comparator, :stat_url, :window

    def logger
      @logger ||= Logger.new(StringIO.new)
    end
    attr_writer :logger

    def triggered?
      values = get_stat
      aggregated = aggregator.call(values)
      logger.info "#{comparator} #{aggregated} (#{aggregator} #{values})"
      comparator.true?(aggregated)
    end

    private

    def get_stat
      stat = read_stat(url = build_url)
      # {"minibuntu" => {"ping" => {"ping_droprate-8.8.8.8" => {"value": {"start" => 1455136836, "finish" => 1455136896, "data" => [0, 0, 0, 0, 0, null]}}}}}
      host_data = stat.values.first
      ping_data = host_data.values.first
      ping_drop = ping_data.values.first
      value_hash = ping_drop.fetch("value")
      value_hash.fetch("data").compact
    rescue => e
      logger.warn "Error while fetching #{url}: #{e.class.name}: #{e}"
      [0]
    end

    def read_stat(url)
      uri = URI(url)
      # http://opensourceconnections.com/blog/2008/04/24/adding-timeout-to-nethttp-get_response/
      http = Net::HTTP.new(uri.host, uri.port)
      http.set_debug_output logger
      http.read_timeout = 5
      http.open_timeout = 5
      raw_json = http.start { |http| http.get(uri.request_uri).body }
      JSON.load(raw_json)
    end

    def build_url
      finish = Time.now.to_i
      start = finish - window.to_i
      "#{stat_url}?start=#{start}&finish=#{finish}"
    end

    class Averager
      def call(values)
        values.map(&:to_f).inject(0, &:+) / values.size
      end

      def to_s
        "average"
      end
    end

    class Max
      def call(values)
        values.map(&:to_f).inject { |a,b| a > b ? a : b }
      end

      def to_s
        "max"
      end
    end

    class Min
      def call(values)
        values.map(&:to_f).inject { |a,b| a < b ? a : b }
      end

      def to_s
        "min"
      end
    end

    class Above
      def initialize(limit)
        @limit = limit.to_f
      end

      def true?(value)
        value > @limit
      end

      def to_s
        "above #{@limit}?"
      end
    end

    class Below
      def initialize(limit)
        @limit = limit.to_f
      end

      def true?(value)
        value < @limit
      end

      def to_s
        "below #{@limit}?"
      end
    end
  end
end
