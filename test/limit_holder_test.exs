defmodule HillelBudget.LimitHolderTest do
  use ExUnit.Case
  alias HillelBudget.LimitHolder

  test "debiting of values" do
    expect = fn [holder, key, amount], expected ->
      assert LimitHolder.decrement(holder, key, amount) == expected
    end

    [%{key: 10}, :key,      8] |> expect.(%{key:  2})
    [%{key: 10}, :MISMATCH, 8] |> expect.(%{key: 10})
  end

end  

