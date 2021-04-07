defmodule HillelBudget.ItemTest do
  use ExUnit.Case
  alias HillelBudget.Item
  import HillelBudget.Item, only: [item: 2]

  describe "normalization" do
    test "normalizing a single item" do
      expect = fn bill, expected ->
        assert Item.normalize(bill) == expected
      end
      
      %{cost: "c"}                    |> expect.([item("c", [        ])])
      %{cost: "c", categories: ["a"]} |> expect.([item("c", ["a"     ])])
      %{cost: "c", categories: ["a", "b"], count: 2}
                                      |> expect.([item("c", ["a", "b"]),
                                                  item("c", ["a", "b"])])
    end
    
    test "normalizing bills" do
      actual = Item.normalize([%{cost: 20, count: 2}])
      assert actual == [item(20, []), item(20, [])]
    end
  end
end
