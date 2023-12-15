# typed: true
# frozen_string_literal: true

module AtlasEngine
  module MetricsHelper
    extend T::Sig

    sig do
      params(
        name: String,
        sample_rate: Float,
        tags: T::Array[String],
        block: T.proc.returns(T.untyped),
      ).returns(T.untyped)
    end
    def measure_distribution(name:, sample_rate: 1.0, tags: [], &block)
      StatsD.distribution(
        name,
        sample_rate: sample_rate,
        tags: tags,
        &block
      )
    end
  end
end
