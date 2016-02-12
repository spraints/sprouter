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
    it { expect(config.pingdrop_threshold).to eq(1.0) }
    it { expect(config.pingdrop_url).to be_nil }
  end

  context "empty options" do
    let(:options) { {} }
    it { expect(config.turbo_sites).to eq([]) }
    it { expect(config.turbo_hosts).to eq([]) }
    it { expect(config.preferred_hosts).to eq([]) }
    it { expect(config.pingdrop_threshold).to eq(1.0) }
    it { expect(config.pingdrop_url).to be_nil }
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
    it { expect(config.pingdrop_threshold).to eq(1.0) }
    it { expect(config.pingdrop_url).to be_nil }
  end

  context "full" do
    let(:options) { YAML.load(<<-YAML) }
      turbo_sites:
        google:
        - www.google.com
        github:
        - github.com
        - gist.github.com

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
        stat: "http://whatever"
        threshold: 0.5
    YAML
    it { expect(config.turbo_sites).to eq(["www.google.com", "github.com", "gist.github.com"]) }
    it { expect(config.turbo_hosts).to eq(["172.16.0.1", "172.16.0.2", "172.16.0.3"]) }
    it { expect(config.preferred_hosts).to eq(["172.16.0.11", "172.16.0.12", "172.16.0.13"]) }
    it { expect(config.pingdrop_threshold).to eq(0.5) }
    it { expect(config.pingdrop_url).to eq("http://whatever") }
  end
end
