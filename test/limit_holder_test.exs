defmodule HillelBudget.LimitHolderTest do
  use ExUnit.Case
  alias HillelBudget.LimitHolder
  import HillelBudget.Item, only: [item: 2]
  use FlowAssertions

  # Forgive me, Bertrand Meyer, but combining the update and the query
  # seems to make handling missing keys easier.

  describe "debiting of values" do
    expect = fn [holder, key, amount], expected ->
      assert LimitHolder.decrement(holder, key, amount) == expected
    end

    [%{key: 10}, :key,      8] |> expect.(%{key:  2})
    [%{key: 10}, :MISMATCH, 8] |> expect.(%{key: 10})

    # Overdrawing
    [%{key: 10}, :key,      10] |> expect.(%{key: 0})
    [%{key: 10}, :key,      11] |> expect.(:overdrawn)
  end

  describe "applying items to a collection of holders" do
    test "the easy category cases: 0 or 1" do
      original = [%{category: 10}]
      
      expect = fn item, expected ->
        assert LimitHolder.apply_item(original, item) == expected
      end

      # cases that do not apply
      item(10, [     ]) |> expect.(original)
      item(10, [:miss]) |> expect.(original)

      # one category, and it matches
      item(10, [:category]) |> expect.([%{category: 0}])
      item(11, [:category]) |> expect.([              ])  # overdrawn
    end


    test "the cases that require splitting" do
      original = [%{cat_a: 10, cat_b: 10}]
      
      expect = fn item, expected ->
        assert LimitHolder.apply_item(original, item) == expected
      end

      # cases that do not apply
      item(10, [     ]) |> expect.(original)
      item(10, [:miss]) |> expect.(original)

      # the need to split
      item(10, [:cat_a])         |> expect.([%{cat_a:  0, cat_b: 10}])
      item(10, [:cat_b])         |> expect.([%{cat_a: 10, cat_b:  0}])
      item(10, [:cat_a, :cat_b]) |> expect.([%{cat_a:  0, cat_b: 10},
                                             %{cat_a: 10, cat_b:  0}])

      # overdrawn cases are pruned
      item(11, [:cat_a])         |> expect.([])
      item(11, [:cat_b])         |> expect.([])
      item(11, [:cat_a, :cat_b]) |> expect.([])
    end
  end

  describe "surviving holders" do 
    test "surviving holders" do
      original = [%{cat_a: 10, cat_b: 10}]
      
      one = item(5, [:cat_a])
      one_step = LimitHolder.surviving_holders(original, [one])
      
      assert one_step == [%{cat_a: 5, cat_b: 10}]
      
      two = item(5, [:cat_a, :cat_b])
      two_step = LimitHolder.surviving_holders(original, [one, two])
      
      assert_good_enough(two_step,
        in_any_order([
          %{cat_a: 0, cat_b: 10},
          %{cat_a: 5, cat_b: 5}
        ]))

      three = item(5, [:cat_a, :cat_b])
      three_step = LimitHolder.surviving_holders(original, [one, two, three])
      
      assert_good_enough(three_step,
        in_any_order([
          %{cat_a: 0, cat_b: 5},
          %{cat_a: 0, cat_b: 5},
          %{cat_a: 5, cat_b: 0},
        ]))
    end

    # This tests a boundary for the optimization
    test "a case where all the holders are discarded before all items used" do
      original = [%{cat_a: 10, cat_b: 10}]
      
      # Demonstrate emptiness
      items = [item(10, [:cat_a]),
               item(5, [:cat_a, :cat_b]),
               item(6, [:cat_b])]
      
      assert [] = LimitHolder.surviving_holders(original, items)

      more_items = items ++ [item(5, [:cat_a, :cat_b])]
      assert [] = LimitHolder.surviving_holders(original, more_items)
    end
  end
end

