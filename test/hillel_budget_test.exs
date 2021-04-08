defmodule HillelBudgetTest do
  use ExUnit.Case
  import HillelBudget

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

  describe "running out of categories" do
    test "total budget boundaries" do
      budget = budget(100, a: 5)
      bill = [%{cost: 20, categories: ["a"]}]

      refute can_afford?(budget, bill)
    end
  end
  # ----------------------------------------------------------------------------

  def budget(total_limit, categories \\ []) do
    %{total_limit: total_limit, category_limits: Map.new(categories)}
  end
end
