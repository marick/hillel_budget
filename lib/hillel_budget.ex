defmodule HillelBudget do
  def remaining_total_after_bill(limit, bill) do
    item_charges = for item <- bill do
      count = Map.get(item, :count, 1)
      item.cost * count
    end
      
    limit - Enum.sum(item_charges)
  end

  def remaining_category_total_after_bill(categories, category, bill_amount) do
    case Map.has_key?(categories, category) do
      true ->
        Map.update!(categories, category, &(&1 - bill_amount))
      false ->
        categories
    end
  end

  def can_afford?(budget, bill) do
    remaining_total_after_bill(budget.total_limit, bill) >= 0
  end

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
