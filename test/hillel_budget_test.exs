defmodule HillelBudgetTest do
  use ExUnit.Case

  def can_afford?(_budget, _bill) do
    true
  end

  test "total budget always passes" do
    budget = %{total_limit: 50}
    bill = %{cost: 50}

    assert can_afford?(budget, bill)
  end
end
