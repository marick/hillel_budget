defmodule HillelBudget do
  alias HillelBudget.{Item,LimitHolder}

  def can_afford?(budget, items) do
    items = Item.normalize(items)

    total_ok = the_total_budget_is_ok(budget.total_limit, items)
    categories_ok = all_category_budgets_are_ok(budget.category_limits, items)

    total_ok && categories_ok
  end
  
  # ----------------------------------------------------------------------------
  
  def the_total_budget_is_ok(limit, items) do
    item_charges = for item <- items do
      count = Map.get(item, :count, 1)
      item.cost * count
    end
      
    limit - Enum.sum(item_charges) >= 0
  end

  def all_category_budgets_are_ok(category_limits, items) do
    not Enum.empty?(LimitHolder.surviving_holders([category_limits], items))
  end
end
