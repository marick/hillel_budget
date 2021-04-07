defmodule HillelBudgetTest do
  use ExUnit.Case

  def total_charge(bill) do
    item_charges = for item <- bill do
      count = Map.get(item, :count, 1)
      item.cost * count
    end
      
    Enum.sum(item_charges)
  end

  def can_afford?(budget, bill) do
    total_charge(bill) <= budget.total_limit
  end

  def budget(total_limit) do
    %{total_limit: total_limit}
  end

  # After beginning to work on categories, I decided I didn't want to
  # have to keep hassling with counts, so add a "normalization" step
  # to clean the data.
  #
  # Besides, I'm guessing this will make things easier later on.

  def normalize(bill) when is_map(bill) do
    cost = bill.cost
    categories = Map.get(bill, :categories, [])
    count = Map.get(bill, :count, 1)

    Enum.map(1..count, fn _ ->
      %{cost: cost, categories: categories}
    end)
  end

  def normalize(bills) when is_list(bills) do
    Enum.flat_map(bills, &normalize/1)
  end

  describe "normalization" do
    test "normalizing a bill" do
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

  describe "total budget" do 
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
