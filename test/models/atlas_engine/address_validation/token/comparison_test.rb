# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/token_helper"

module AtlasEngine
  module AddressValidation
    class Token
      class ComparisonTest < ActiveSupport::TestCase
        include AddressValidation::TokenHelper

        setup do
          @klass = AddressValidation::Token::Comparison
        end

        test "sort order" do
          token_1 = token(value: "token_1")
          token_2 = token(value: "token_2")

          equal_0 = token_comparison(left: token_1, right: token_2, qualifier: :equal)
          equal_0_copy = token_comparison(left: token_1, right: token_2, qualifier: :equal)
          prefix_2 = token_comparison(left: token_1, right: token_2, qualifier: :prefix, edit: 2)
          prefix_4 = token_comparison(left: token_1, right: token_2, qualifier: :prefix, edit: 4)
          suffix_2 = token_comparison(left: token_1, right: token_2, qualifier: :suffix, edit: 2)
          comp_2 = token_comparison(left: token_1, right: token_2, qualifier: :comp, edit: 2)

          assert_equal 0,  equal_0  <=> equal_0_copy
          assert_equal(-1, equal_0  <=> prefix_2)
          assert_equal 1,  prefix_2 <=> equal_0
          assert_equal(-1, prefix_2 <=> prefix_4)
          assert_equal(-1, prefix_2 <=> suffix_2)
          assert_equal 1,  prefix_4 <=> suffix_2
          assert_equal 1,  prefix_4 <=> comp_2
          assert_equal(-1, suffix_2 <=> comp_2)
        end

        test "inspect" do
          t1 = token(value: "A")
          t2 = token(value: "Eh!")
          comparison = token_comparison(left: t1, right: t2, qualifier: :comp, edit: 3)
          assert_match(
            %r{<comp left:<tok id:\d{4} val:"A" strt:0 end:0 pos:0/> COMP right:<tok id:\d{4} val:"Eh!" .+/> edit:3/>},
            comparison.inspect,
          )
        end

        test "#equal? is truthy when qualifier is :equal" do
          token_1 = token(value: "token_1")
          token_2 = token(value: "token_2")

          equal_0 = token_comparison(left: token_1, right: token_2, qualifier: :equal)
          prefix_2 = token_comparison(left: token_1, right: token_2, qualifier: :prefix, edit: 2)

          assert_predicate equal_0, :equal?
          assert_not_predicate prefix_2, :equal?
        end

        test "#preceeds? is truthy when my left and right token positions are each one less than their counterpart /
            positions in the other comparison" do
          # token values don't matter here.  Only their positions
          left_pos_0 = token(value: "left_pos_0", position: 0)
          left_pos_1 = token(value: "left_pos_1", position: 1)
          left_pos_2 = token(value: "left_pos_2", position: 2)
          right_pos_3 = token(value: "right_pos_3", position: 3)
          right_pos_4 = token(value: "right_pos_4", position: 4)

          left_0_right_3 = token_comparison(left: left_pos_0, right: right_pos_3, qualifier: :equal)
          left_1_right_4 = token_comparison(left: left_pos_1, right: right_pos_4, qualifier: :prefix, edit: 2)
          left_2_right_4 = token_comparison(left: left_pos_2, right: right_pos_4, qualifier: :prefix, edit: 2)

          # left.position is one less than other.left.position AND right.position is one less than other.right.position
          assert left_0_right_3.preceeds?(left_1_right_4)
          assert_not left_1_right_4.preceeds?(left_0_right_3)
          assert_not left_0_right_3.preceeds?(left_2_right_4)
        end

        test "#preceeds? uses position_length to determine the expected jump in position" do
          # token values don't matter here.  Only their positions
          left_pos_0 = token(value: "left_pos_0", position: 0, position_length: 2)
          left_pos_1 = token(value: "left_pos_1", position: 1)
          left_pos_2 = token(value: "left_pos_2", position: 2)
          right_pos_3 = token(value: "right_pos_3", position: 3)
          right_pos_4 = token(value: "right_pos_4", position: 4)

          left_0_right_3 = token_comparison(left: left_pos_0, right: right_pos_3, qualifier: :equal)
          left_1_right_4 = token_comparison(left: left_pos_1, right: right_pos_4, qualifier: :prefix, edit: 2)
          left_2_right_4 = token_comparison(left: left_pos_2, right: right_pos_4, qualifier: :prefix, edit: 2)

          assert left_0_right_3.preceeds?(left_2_right_4) # left token jumps 2 positions, right token jumps 1 position
          assert_not left_2_right_4.preceeds?(left_0_right_3)
          assert_not left_0_right_3.preceeds?(left_1_right_4)
        end
      end
    end
  end
end
