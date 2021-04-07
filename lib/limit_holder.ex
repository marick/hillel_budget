defmodule HillelBudget.LimitHolder do

  @moduledoc """
  A limit-holder is a map of key-value pairs where the pairs are
  integers that represent a limit on spending. The limits may be
  negative if spending has exceeded the limit.
  """

  def decrement(holder, key, amount) do
    case Map.has_key?(holder, key) do
      true ->
        Map.update!(holder, key, &(&1 - amount))
      false ->
        holder
    end
  end
end
