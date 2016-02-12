require "spec_helper"

require "sprouter/ping_check"

describe Sprouter::PingCheck do
  context "#build" do
    subject(:ping_check) { described_class.build(config) }

    context "nil config" do
      let(:config) { nil }
      it { expect(ping_check.triggered?).to be_falsy }
    end

    context "empty config" do
      let(:config) { {} }
      it { expect(ping_check.triggered?).to be_falsy }
    end

    context do
      # Stub the method that gets the stat from the metrics server.
      before { allow(ping_check).to receive(:get_stat).and_return(values) }

      context "mode=average" do
        let(:config) { {"mode" => "average", "above" => "0.5", "stat_url" => "http://whatever", "window" => 60} }
        context "stat is under" do
          let(:values) { [0, 1, 0] }
          it { expect(ping_check.triggered?).to be_falsy }
        end
        context "stat is over" do
          let(:values) { [1, 0, 1] }
          it { expect(ping_check.triggered?).to be_truthy }
        end
      end

      context "mode=all" do
        let(:config) { {"mode" => "all", "below" => "0.5", "stat_url" => "http://whatever", "window" => 60} }
        context "stat is over, but average is under" do
          let(:values) { [0, 1, 0] }
          it { expect(ping_check.triggered?).to be_falsy }
        end
        context "stat is over, and average is over" do
          let(:values) { [1, 0, 1] }
          it { expect(ping_check.triggered?).to be_falsy }
        end
        context "stat is under" do
          let(:values) { [0.499, 0.499, 0.499] }
          it { expect(ping_check.triggered?).to be_truthy }
        end
        context "stat is over" do
          let(:values) { [0.501, 0.501, 0.501] }
          it { expect(ping_check.triggered?).to be_falsy }
        end
      end
    end
  end
end
