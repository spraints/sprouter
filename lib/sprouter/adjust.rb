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

      if go_faster?
        set preferred_host_ips + turbo_host_ips
      elsif go_slower?
        set turbo_host_ips
      else
        set pf.table_entries("turbo_hosts") + turbo_host_ips
      end
    end

    def set(ips)
      if ips.any?
        pf.set_table "turbo_hosts", ips.sort.uniq
      else
        pf.flush_table "turbo_hosts"
      end
    end

    def go_faster?
      test config.go_faster
    end

    def go_slower?
      test config.go_slower
    end

    def test(predicate)
      predicate.logger = logger
      predicate.triggered?
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
