defmodule HillelBudget.Item do
  defstruct [:cost, :categories]

  def item(cost, categories),
    do: %__MODULE__{cost: cost, categories: categories}

  def normalize(bill) when is_list(bill),
    do: Enum.flat_map(bill, &normalize/1)

  def normalize(item) when is_map(item) do
    cost = item.cost
    categories = Map.get(item, :categories, []) |> Enum.map(&String.to_atom/1)
    count = Map.get(item, :count, 1)

    Enum.map(1..count, fn _ -> item(cost, categories) end)
  end

  # This could go in `normalize`, but it provides an optimization and
  # I'd like its use to be with the other optimations. 
  # Quite possibly that means this should live somewhere else.
  def favor_fewer_categories(bill) do
    Enum.sort(bill, &(length(&1.categories) <= length(&2.categories)))
  end
end

