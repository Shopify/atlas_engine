# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  class MetricsHelperTest < ActiveSupport::TestCase
    include StatsD::Instrument::Assertions
    class DummyClass
      include MetricsHelper
    end

    test "measure_distribution measures the execution duration of the given block" do
      metric_name = "my_metric"
      sample_rate = 0.5
      tags = ["tag1", "tag2"]

      assert_statsd_distribution(metric_name, sample_rate: sample_rate, tags: tags) do
        DummyClass.new.measure_distribution(name: metric_name, sample_rate: sample_rate, tags: tags) do
          "my block"
        end
      end
    end

    test "measure_distribution measures does not require a sample_rate" do
      metric_name = "my_metric"
      tags = ["tag1", "tag2"]

      assert_statsd_distribution(metric_name, sample_rate: 1.0, tags: tags) do
        DummyClass.new.measure_distribution(name: metric_name, tags: tags) do
          "my block"
        end
      end
    end

    test "measure_distribution measures does not require tags" do
      metric_name = "my_metric"
      sample_rate = 0.5

      assert_statsd_distribution(metric_name, sample_rate: sample_rate, tags: []) do
        DummyClass.new.measure_distribution(name: metric_name, sample_rate: sample_rate) do
          "my block"
        end
      end
    end
  end
end
