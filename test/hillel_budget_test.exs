defmodule HillelBudgetTest do
  use ExUnit.Case
  import HillelBudget
  doctest HillelBudget
  
  describe "total budget alone" do 
    test "total budget boundaries" do
      assert can_afford?(budget(50), %{cost: 50})
      refute can_afford?(budget(49), %{cost: 50})
    end

    test "affordability" do
      success_message = "Total budget remaining: 0"
      assert {true, ^success_message, _, [%{}]} = 
        affordability(budget(50), %{cost: 50})
      
      error_msg = "Total limit is exceeded by 1."
      assert affordability(budget(49), %{cost: 50}) == {false, error_msg}
    end

    test "bill items can have counts" do
      bill = [%{cost: 20}, %{cost: 20, count: 2}]
      assert can_afford?(budget(60), bill)
      refute can_afford?(budget(59), bill)

      error_msg = "Total limit is exceeded by 1."
      assert affordability(budget(59), bill) == {false, error_msg}
    end
  end

  describe "running out of category limit amounts" do
    test "boundaries" do 
      bill = [%{cost: 5, categories: ["a"], count: 2}]

      assert can_afford?(budget(100, a: 10), bill)
      refute can_afford?(budget(100, a:  9), bill)
    end

    test "affordability" do 
      bill = [%{cost: 5, categories: ["a"], count: 2}]

      success_message = "Total budget remaining: 90"
      assert {true, ^success_message, _, [%{a: 0}]} =
        affordability(budget(100, a: 10), bill)
      
      error_msg = "There is no way to avoid *some* category's limit being exceeed."
      assert affordability(budget(100, a:  9), bill) == {false, error_msg}
    end
  end
  # ----------------------------------------------------------------------------

  def budget(total_limit, categories \\ []) do
    %{total_limit: total_limit, category_limits: Map.new(categories)}
  end
end
