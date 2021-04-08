defmodule HillelBudget.LimitHolderTest do
  use ExUnit.Case
  alias HillelBudget.LimitHolder
  import HillelBudget.Item, only: [item: 2]
  use FlowAssertions

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
    test "the easy category cases (0 or 1) require no splitting" do
      original = [%{category: 10}]
      expect = &(assert LimitHolder.apply_item(original, &1) == &2)

      # cases that do not apply
      item(10, [     ]) |> expect.(original)
      item(10, [:miss]) |> expect.(original)

      # one category, and it matches
      item(10, [:category]) |> expect.([%{category: 0}])
      item(11, [:category]) |> expect.([              ])  # overdrawn
    end


    test "the cases that require splitting" do
      original = [%{cat_a: 10, cat_b: 10}]
      expect = &(assert LimitHolder.apply_item(original, &1) == &2)

      # the need to split (3) compared to no need (1 and 2)
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
    test "a step-by-step example" do
      original = [%{cat_a: 10, cat_b: 10}]
      steps = &(LimitHolder.surviving_holders(original, &1))
      
      one = item(5, [:cat_a])
      assert steps.([one]) == [%{cat_a: 5, cat_b: 10}]
      
      two = item(5, [:cat_a, :cat_b])
      assert_good_enough(steps.([one, two]),
        in_any_order([
          %{cat_a: 0, cat_b: 10},
          %{cat_a: 5, cat_b: 5}
        ]))

      three = item(5, [:cat_a, :cat_b])
      assert_good_enough(steps.([one, two, three]),
        in_any_order([
          # Note that a duplicate instance of the following is removed.
          %{cat_a: 0, cat_b: 5},
          %{cat_a: 5, cat_b: 0},
        ]))
    end

    # This exercises a boundary in the optimized version that would not
    # be one in the straightforward one.
    test "a case where all the holders are discarded before all items used" do
      original = [%{cat_a: 10, cat_b: 10}]
      
      # Demonstrate emptiness with three steps
      items = [item(10, [:cat_a]),
               item(5, [:cat_a, :cat_b]),
               item(6, [:cat_b])]
      assert [] = LimitHolder.surviving_holders(original, items)

      # More steps change nothing.
      more_items = items ++ [item(5, [:cat_a, :cat_b])]
      assert [] = LimitHolder.surviving_holders(original, more_items)
    end
  end
end

