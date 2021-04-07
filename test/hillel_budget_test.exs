defmodule HillelBudgetTest do
  use ExUnit.Case

  # Next step, I'll be working on debiting from categories, so I should treat the
  # total the same way.
  
  def remaining_total_after_bill(limit, bill) do
    item_charges = for item <- bill do
      count = Map.get(item, :count, 1)
      item.cost * count
    end
      
    limit - Enum.sum(item_charges)
  end

  def can_afford?(budget, bill) do
    remaining_total_after_bill(budget.total_limit, bill) >= 0
  end

  def budget(total_limit) do
    %{total_limit: total_limit}
  end

  # I noticed that I'd gotten my terminology messed up, using "bills and bill"
  # instead of "bill and item"

  def normalize(item) when is_map(item) do
    cost = item.cost
    categories = Map.get(item, :categories, [])
    count = Map.get(item, :count, 1)

    Enum.map(1..count, fn _ ->
      %{cost: cost, categories: categories}
    end)
  end

  def normalize(bill) when is_list(bill) do
    Enum.flat_map(bill, &normalize/1)
  end

  describe "normalization" do
    test "normalizing a single item" do
      expect = fn bill, expected ->
        assert normalize(bill) == expected
      end
      
      %{cost: "c"}                    |> expect.([%{cost: "c", categories: []}])
      %{cost: "c", categories: ["a"]} |> expect.([%{cost: "c", categories: ["a"]}])
      %{cost: "c", categories: ["a", "b"], count: 2}
                                      |> expect.([%{cost: "c", categories: ["a", "b"]},
                                                  %{cost: "c", categories: ["a", "b"]}])
    end

    test "normalizing bills" do
      actual = normalize([%{cost: 20, count: 2}])
      assert actual == [%{cost: 20, categories: []},
                        %{cost: 20, categories: []}]
    end
  end

  describe "total budget alone" do 
    test "total budget boundaries" do
      bill = [%{cost: 50}]
      
      assert can_afford?(budget(50), bill)
      refute can_afford?(budget(49), bill)
    end

    test "bill items can have counts" do
      bill = [%{cost: 20}, %{cost: 20, count: 2}]
      assert can_afford?(budget(60), bill)
      refute can_afford?(budget(59), bill)
    end
  end

  describe "interaction of limits" do
    @tag :skip
    test "category with total"
  end
  
end
