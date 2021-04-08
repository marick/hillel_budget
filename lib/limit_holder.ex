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

  # Normally, these optimizations would wait to see if they're needed, but
  # let's give PBT more to chew on.
  # 1. sort items with fewer categories to the front. (postpone splitting)
  # 2. stop short when there are no holders left, even if there are items left.
  
  
  def surviving_holders(holders, items) do
    optimized_holders = Item.favor_fewer_categories(holders)
    
    Enum.reduce_while(items, optimized_holders, fn item, acc ->
      # The flipping of the arguments to apply_item may suggests that some
      # or all of this code belongs in `Item`?
      case apply_item(acc, item) do
        [] -> {:halt, []}
        next_acc -> {:cont, next_acc}
      end
    end)
  end
end
