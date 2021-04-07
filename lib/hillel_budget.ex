defmodule HillelBudget do
  alias HillelBudget.Item
  
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

  # Interesting. I failed to normalize the bill. 

  def can_afford?(budget, bill) do
    items = Item.normalize(bill)
    remaining_total_after_bill(budget.total_limit, items) >= 0
  end

end
