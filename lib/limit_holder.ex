defmodule HillelBudget.LimitHolder do
  alias HillelBudget.Item

  @moduledoc """
  A limit-holder is a map of key-value pairs where the pairs are
  integers that represent a limit on spending. The limits may be
  negative if spending has exceeded the limit.
  """

  def decrement(holder, key, amount) do
    case Map.has_key?(holder, key) do
      true ->
        new_balance = Map.get(holder, key) - amount
        if new_balance < 0 do
          :overdrawn
        else
          Map.put(holder, key, new_balance)
        end
      false ->
        holder
    end
  end

  # It's probably simpler, in terms of code, to generate all
  # combinations of a bill, then apply them to a a single
  # holder/budget. However, doing things breadth first is more
  # efficient and (I speculate) gives property-based testing more
  # opportunities to find bugs. Because it's pruning a search tree at the
  # same time it's being generated


  def apply_item(holders, %Item{categories: []}), do: holders

  def apply_item(holders, item) do
    item.categories
    |> Enum.flat_map(fn category ->
        for holder <- holders, do: decrement(holder, category, item.cost)
       end)
    |> Enum.reject(&(&1 == :overdrawn))
  end
end
