defmodule HillelBudget.ItemTest do
  use ExUnit.Case
  alias HillelBudget.Item
  import HillelBudget.Item, only: [item: 2]

  describe "normalization" do
    test "normalizing a single item" do
      expect = fn bill, expected ->
        assert Item.normalize(bill) == expected
      end

      c = 535 # This represents some random cost.
      
      %{cost: c}                    |> expect.([item(c, [        ])])
      %{cost: c, categories: ["a"]} |> expect.([item(c, [:a     ])])
      %{cost: c, categories: ["a", "b"], count: 2}
                                    |> expect.([item(c, [:a, :b]),
                                                item(c, [:a, :b])])
    end
    
    test "normalizing bills" do
      actual = Item.normalize([%{cost: 20, count: 2}])
      assert actual == [item(20, []), item(20, [])]
    end
  end

  test "sorting fewer category items to the front" do
    one = item(1, [])
    two = item(2, [:a])
    three = item(3, [:a, :b])
    four = item(4, [:a, :b, :c])
    
    actual = Item.favor_fewer_categories([four, two, one, three])
    assert actual == [one, two, three, four]
  end
end
