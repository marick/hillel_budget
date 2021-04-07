defmodule HillelBudget do
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
end
