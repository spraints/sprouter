require "json"
require "logger"
require "net/http"
require "resolv"
require "stringio"
require "yaml"
require_relative "pf"

module Sprouter
  class Adjust
    def initialize(pf: PF.new, logger: Logger.new(StringIO.new))
      @pf = pf
      @logger = logger
    end

    attr_reader :pf, :logger

    def run!(config_path)
      info = YAML.load(File.read(config_path))

      update_turbo_sites info
      update_turbo_hosts info
    end

    private

    ###
    # turbo_sites

    def update_turbo_sites(info)
      turbo_sites = info.fetch("turbo_sites")
      turbo_site_ips = lookup_ips(turbo_sites.values.inject(&:+))
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

    def update_turbo_hosts(info)
      if pingdroppin?(info.fetch("config"))
        turbo_hosts_config = info.fetch("turbo_hosts")
        turbo_host_ips = turbo_hosts_config.values.inject(&:+)
        pf.set_table "turbo_hosts", turbo_host_ips
      else
        pf.flush_table "turbo_hosts"
      end
    end

    def pingdroppin?(config)
      config.fetch("threshold", 1).to_f < average_pingdrop(config.fetch("stat"))
    end

    def average_pingdrop(stat_url)
      finish = Time.now.to_i
      start = finish - 60
      uri = URI("#{stat_url}?start=#{start}&finish=#{finish}")
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
  end
end
