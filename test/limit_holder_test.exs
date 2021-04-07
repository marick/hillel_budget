defmodule HillelBudget.LimitHolderTest do
  use ExUnit.Case
  alias HillelBudget.LimitHolder
  import HillelBudget.Item, only: [item: 2]

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
end  

