defmodule HackerAggregatorWeb.FallbackController do
  use HackerAggregatorWeb, :controller

  def call(conn, :error) do
    conn
    |> put_status(400)
    |> put_view(HackerAggregatorWeb.ErrorView)
    |> render(:"400")
  end

  def call(conn, {_num, _str}) do
    conn
    |> put_status(400)
    |> put_view(HackerAggregatorWeb.ErrorView)
    |> render(:"400")
  end

  def call(conn, nil) do
    conn
    |> put_status(404)
    |> put_view(HackerAggregatorWeb.ErrorView)
    |> render(:"404")
  end
end
