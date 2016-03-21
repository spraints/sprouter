require "spec_helper"
require "yaml"

require "sprouter/config"

describe Sprouter::Config do
  subject(:config) { described_class.new(options) }

  context "blank options" do
    let(:options) { nil }
    it { expect(config.turbo_sites).to eq([]) }
    it { expect(config.turbo_hosts).to eq([]) }
    it { expect(config.preferred_hosts).to eq([]) }
    it { expect(config.go_faster).to be_a(Sprouter::PingCheck) }
    it { expect(config.go_slower).to be_a(Sprouter::PingCheck) }
  end

  context "empty options" do
    let(:options) { {} }
    it { expect(config.turbo_sites).to eq([]) }
    it { expect(config.turbo_hosts).to eq([]) }
    it { expect(config.preferred_hosts).to eq([]) }
    it { expect(config.go_faster).to be_a(Sprouter::PingCheck) }
    it { expect(config.go_slower).to be_a(Sprouter::PingCheck) }
  end

  context "top-level only" do
    let(:options) { YAML.load(<<-YAML) }
      turbo_sites:
      turbo_hosts:
      preferred_hosts:
      config:
    YAML
    it { expect(config.turbo_sites).to eq([]) }
    it { expect(config.turbo_hosts).to eq([]) }
    it { expect(config.preferred_hosts).to eq([]) }
    it { expect(config.go_faster).to be_a(Sprouter::PingCheck) }
    it { expect(config.go_slower).to be_a(Sprouter::PingCheck) }
  end

  context "full" do
    let(:options) { YAML.load(<<-YAML) }
      turbo_sites:
        google:
        - www.google.com
        github:
        - github.com
        - gist.github.com

      slow_sites:
        bizarre:
        - www.catb.org

      turbo_hosts:
        mine:
        - 172.16.0.1
        kids:
        - 172.16.0.2
        - 172.16.0.3

      preferred_hosts:
        pets:
        - 172.16.0.11
        phones:
        - 172.16.0.12
        - 172.16.0.13

      config:
        go_faster:
          stat_url: "http://whatever"
          window: 60
          mode: average
          above: 0.5
        go_slower:
          stat_url: "http://whatever"
          window: 300
          mode: all
          below: 0.2
    YAML
    it { expect(config.turbo_sites).to eq(["www.google.com", "github.com", "gist.github.com"]) }
    it { expect(config.slow_sites).to eq(["www.catb.org"]) }
    it { expect(config.turbo_hosts).to eq(["172.16.0.1", "172.16.0.2", "172.16.0.3"]) }
    it { expect(config.preferred_hosts).to eq(["172.16.0.11", "172.16.0.12", "172.16.0.13"]) }
    it { expect(config.go_faster).to be_a(Sprouter::PingCheck) }
    it { expect(config.go_slower).to be_a(Sprouter::PingCheck) }
  end
end
