# typed: true
# frozen_string_literal: true

module Enumerable
  extend T::Sig

  raise "Enumerable#stable_sort_by is already defined" if method_defined?(:stable_sort_by)

  sig do
    params(
      block: T.proc.params(arg0: T.untyped).returns(T.any(Comparable, T::Array[BasicObject])),
    )
      .returns(T::Array[T.untyped])
  end
  def stable_sort_by(&block)
    sort_by.with_index { |x, i| [yield(x), i] }
  end
end
