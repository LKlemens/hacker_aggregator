defmodule HackerAggregatorWeb.HackerNewsController do
  use HackerAggregatorWeb, :controller

  alias HackerAggregator.Core.Pagination

  action_fallback(HackerAggregatorWeb.FallbackController)

  def index(conn, %{"page" => page}) do
    with {num, ""} <- Integer.parse(page) do
      pagination_struct = HackerAggregator.get_page(num)

      conn
      |> validate_pagination(pagination_struct)
      |> render("index.json", pagination_struct: pagination_struct)
    end
  end

  def validate_pagination(conn, pagination_struct) do
    case pagination_struct do
      %Pagination{error: ""} ->
        conn

      %Pagination{
        error: "No stories avaible now, please try again in a few moments"
      } ->
        conn
        |> put_status(503)
        |> put_resp_header("retry-after", "10")

      _ ->
        conn
        |> put_status(404)
    end
  end
end
