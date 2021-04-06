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
end
