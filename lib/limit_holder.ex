defmodule HillelBudget.LimitHolder do

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
end
