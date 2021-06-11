defmodule HackerAggregatorWeb.FallbackController do
  use HackerAggregatorWeb, :controller

  def call(conn, :error) do
    conn
    |> put_status(400)
    |> put_view(HackerAggregatorWeb.ErrorView)
    |> render(:"400")
  end

  def call(conn, {num, str}) do
    conn
    |> put_status(400)
    |> put_view(HackerAggregatorWeb.ErrorView)
    |> render(:"400")
  end
end
