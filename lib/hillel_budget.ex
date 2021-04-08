defmodule HillelBudget do
  alias HillelBudget.{Item,LimitHolder}


  @doc ~S"""
  A solution to Hillel Wayne's [PBT / Example Testing comparison problem](https://gist.github.com/hwayne/e5a65b48ab50a2285de47cfc11fc955f)

  ## Examples

  The following is allowed because the cost of 2 can be assigned to
  category b:

  iex> budget = %{total_limit: 5, category_limits: %{a: 1, b: 3}}
  iex> bill = [%{cost: 2, categories: ["a", "b"]}]
  iex> can_afford?(budget, bill)
  true
  iex> ##############################################################
  iex> # You might think the following would blow the budget for `b`:
  iex> bill = [
  ...>   %{cost: 2, categories: ["a", "b"]},
  ...>   %{cost: 1, count: 2, categories: ["a", "b"]}
  ...> ]
  iex> # ... but:
  iex> can_afford?(budget, bill)
  true
  iex> #
  iex> # To see what's going on, use `affordability` instead of
  ...> # `can_afford?`
  ...> #
  iex> affordability(budget, bill)
  {true, "Total budget remaining: 1", "Possible category budget allocations follow", [%{a: 0, b: 0}]}
  iex> #
  iex> # So the sequence of events was:
  iex> # 1. 2 was deducted from `b`, leaving {a: 1, b: 1}
  iex> # 2. 1 was deducted from both 'a' and 'b'. That is, the two separate
  iex> #     counts were treated separately.
  iex> #
  iex> ##############################################################
  iex> # A further item with no categories won't break the budget, though it will
  iex> # reduce the total down to 0:
  iex> affordability(budget, bill ++ [%{cost: 1}])
  {true, "Total budget remaining: 0", "Possible category budget allocations follow", [%{a: 0, b: 0}]}
  iex> #
  iex> ##############################################################
  iex> # But putting that final wafer-thin charge into a category instead
  iex> # of no category will (at last!) break the budget.
  iex> #
  iex> can_afford?(budget, bill ++ [%{cost: 1, categories: ["a"]}])
  false

  Here's a larger example of a budget. Note that some items might refer
  to categories without budgets.

  iex> budget = %{
  ...>   total_limit: 50,
  ...>   category_limits: %{
  ...>     food: 10,
  ...>     rent: 11,
  ...>     candles: 49
  ...>   }
  ...> }
  iex> bill = [
  ...>   %{cost: 5},
  ...>   %{cost: 1, count: 3},
  ...>   %{cost: 2, categories: ["food", "gym"]},
  ...>   %{cost: 1, count: 2, categories: ["transit"]}
  ...> ]
  iex> HillelBudget.can_afford?(budget, bill)
  true
  """
  def can_afford?(budget, items) do
    case affordability(budget, items) do
      {false, _} -> false
      {true, _, _, _} -> true
    end
  end

  @doc false
  def affordability(budget, items) do
    items = Item.normalize(items)
    total_charges = (for item <- items, do: item.cost) |> Enum.sum
    remaining = budget.total_limit - total_charges

    case remaining < 0 do
      true ->
        {false, "Total limit is exceeded by #{-remaining}."}
      false -> 
        case LimitHolder.surviving_holders(budget.category_limits, items) do
          [] ->
            {false, "There is no way to avoid *some* category's limit being exceeed."}
          surviving_holders ->
            {true, "Total budget remaining: #{remaining}",
                   "Possible category budget allocations follow",
                   surviving_holders}
        end
    end
  end
end
