defmodule HillelBudgetTest do
  use ExUnit.Case
  import HillelBudget

  test "debiting of categories" do
    expect = fn [categories, category, amount], expected ->
      actual = remaining_category_total_after_bill(categories, category, amount)
      assert actual == expected
    end

    [%{category: 10}, :category, 8] |> expect.(%{category:  2})
    [%{category: 10}, :MISMATCH, 8] |> expect.(%{category: 10})
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


  # ----------------------------------------------------------------------------

  # Note that these are normalized items. Getting close to wanting
  # a structure. Heck, let's do it.
  def item(cost, categories) do
    %{cost: cost, categories: categories}
  end

  # I realized that budget really belongs here
  def budget(total_limit) do
    %{total_limit: total_limit}
  end

  
  
end
