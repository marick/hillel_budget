defmodule HillelBudget do
  alias HillelBudget.Item
  
  def the_total_budget_is_ok(limit, bill) do
    item_charges = for item <- bill do
      count = Map.get(item, :count, 1)
      item.cost * count
    end
      
    limit - Enum.sum(item_charges) >= 0
  end

  def can_afford?(budget, bill) do
    items = Item.normalize(bill)

    total_ok = the_total_budget_is_ok(budget.total_limit, items)
    categories_ok = true

    total_ok && categories_ok
  end
end
