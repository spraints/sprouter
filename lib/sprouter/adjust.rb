require "json"
require "net/http"
require "resolv"
require "stringio"
require "yaml"
require_relative "pf"

module Sprouter
  class Adjust
    def initialize(pf: PF.new, logger:, config:)
      @pf = LoggingPf.new(pf, logger)
      @logger = logger
      @config = config
    end

    attr_reader :pf, :logger, :config

    def run!
      update_turbo_sites
      update_turbo_hosts
    end

    private

    ###
    # turbo_sites

    def update_turbo_sites
      turbo_site_ips = lookup_ips(config.turbo_sites)
      pf.set_table "turbo_sites", turbo_site_ips
    end

    def lookup_ips(hostnames)
      Resolv::DNS.open do |dns|
        hostnames.each_with_object([]) do |hostname, ips|
          dns.each_address(hostname) do |address|
            if address.is_a?(Resolv::IPv4)
              ips << address.to_s
            end
          end
        end
      end
    end

    ###
    # turbo_hosts

    def update_turbo_hosts
      turbo_host_ips = config.turbo_hosts
      preferred_host_ips = config.preferred_hosts
      if pingdroppin?
        pf.set_table "turbo_hosts", preferred_host_ips + turbo_host_ips
      elsif turbo_host_ips.any?
        pf.set_table "turbo_hosts", turbo_host_ips
      else
        pf.flush_table "turbo_hosts"
      end
    end

    def pingdroppin?
      config.pingdrop_threshold < average_pingdrop
    end

    def average_pingdrop
      finish = Time.now.to_i
      start = finish - 60
      uri = URI("#{config.pingdrop_url}?start=#{start}&finish=#{finish}")
      raw_json = Net::HTTP.get_response(uri).body
      result = JSON.load(raw_json)
      # {"minibuntu" => {"ping" => {"ping_droprate-8.8.8.8" => {"value": {"start" => 1455136836, "finish" => 1455136896, "data" => [0, 0, 0, 0, 0, null]}}}}}
      host_data = result.values.first
      ping_data = host_data.values.first
      ping_drop = ping_data.values.first
      value_hash = ping_drop.fetch("value")
      data = value_hash.fetch("data").compact.map(&:to_f)
      avg = data.inject(&:+) / data.size
      logger.info "Average pingdrop: #{avg} (#{data.size} samples)"
      avg
    end

    class LoggingPf
      def initialize(pf, logger)
        @pf = pf
        @logger = logger
      end

      def set_table(table, ips)
        @logger.info "set #{table}'s IPs to #{ips.inspect}"
        @pf.set_table(table, ips)
      end

      def flush_table(table)
        @logger.info "flush #{table}'s IPs"
        @pf.flush_table(table)
      end

      def method_missing(*args)
        @pf.send(*args)
      end
    end
  end
end
