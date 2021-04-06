defmodule HillelBudgetTest do
  use ExUnit.Case

  def can_afford?(budget, bill) do
    total_charge =
      (for item <- bill, do: item.cost)
      |> Enum.sum
    total_charge <= budget.total_limit
  end

  def budget(total_limit) do
    %{total_limit: total_limit}
  end

  test "total budget boundaries" do
    bill = [%{cost: 50}]

    assert can_afford?(budget(50), bill)
    refute can_afford?(budget(49), bill)
  end
end
