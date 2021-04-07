defmodule HillelBudget.LimitHolderTest do
  use ExUnit.Case
  alias HillelBudget.LimitHolder

  # Forgive me, Bertrand Meyer, but combining the update and the query
  # seems to make handling missing keys easier.
  
  test "debiting of values" do
    expect = fn [holder, key, amount], expected ->
      assert LimitHolder.decrement(holder, key, amount) == expected
    end

    [%{key: 10}, :key,      8] |> expect.(%{key:  2})
    [%{key: 10}, :MISMATCH, 8] |> expect.(%{key: 10})

    # Overdrawing
    [%{key: 10}, :key,      10] |> expect.(%{key: 0})
    [%{key: 10}, :key,      11] |> expect.(:overdrawn)
  end

end  

