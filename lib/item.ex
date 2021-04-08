defmodule HillelBudget.Item do
  defstruct [:cost, :categories]

  def item(cost, categories), do: %__MODULE__{cost: cost, categories: categories}

  def normalize(item) when is_map(item) do
    cost = item.cost
    categories = Map.get(item, :categories, []) |> Enum.map(&String.to_atom/1)
    count = Map.get(item, :count, 1)

    Enum.map(1..count, fn _ -> item(cost, categories) end)
  end

  def normalize(bill) when is_list(bill) do
    Enum.flat_map(bill, &normalize/1)
  end

  # This could go in `normalize`, but it's about optimization and I prefer
  # all that be done in one place.
  def favor_fewer_categories(bill) do
    Enum.sort(bill, &(length(&1.categories) <= length(&2.categories)))
  end
end

