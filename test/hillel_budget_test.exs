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

  describe "interaction of limits" do
    @tag :skip
    test "category with total"
  end

  # ----------------------------------------------------------------------------


  def budget(total_limit) do
    %{total_limit: total_limit}
  end

  
  
end
