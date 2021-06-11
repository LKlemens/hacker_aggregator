defmodule HackerAggregatorWeb.HackerNewsView do
  def render("index.json", %{pagination_struct: pagination_struct}) do
    pagination_struct
  end
end
