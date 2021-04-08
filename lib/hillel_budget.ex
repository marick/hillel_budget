defmodule HillelBudget do
  alias HillelBudget.{Item,LimitHolder}

  def can_afford?(budget, items) do
    items = Item.normalize(items)

    if the_total_budget_is_ok?(budget.total_limit, items), 
    do: all_category_budgets_are_ok?(budget.category_limits, items),
    else: false
  end
  
  # ----------------------------------------------------------------------------
  
  def the_total_budget_is_ok?(limit, items) do
    item_charges = for item <- items, do: item.cost
    limit >= Enum.sum(item_charges)
  end

  def all_category_budgets_are_ok?(category_limits, items) do
    case LimitHolder.surviving_holders([category_limits], items) do
      [] -> false
      _ -> true
    end
  end
end
