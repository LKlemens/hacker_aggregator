defmodule HackerAggregatorTest do
  use ExUnit.Case, async: true
  import Mox
  import ExUnit.CaptureLog

  alias HackerAggregator.Core.Story

  setup :verify_on_exit!

  describe "get_list/1" do
  end

  test "success: pass N number, get N stories" do
    num = Enum.random(1..10)
    list = HackerAggregator.get_list(num)
    assert length(list) == num
  end

  test "success: get empty story all time, returns empty list" do
    num = Enum.random(1..10)

    {:ok, list_of_stories_is} = fetch_top_stories_mock()

    HackerAggregator.MockHackerNewsApi
    |> expect(:fetch_top_stories, 1, fn ->
      {:ok, list_of_stories_is}
    end)

    HackerAggregator.MockHackerNewsApi
    |> expect(:fetch_story, length(list_of_stories_is), fn _ -> %{} end)

    log =
      capture_log([level: :error], fn ->
        list = HackerAggregator.get_list(num, HackerAggregator.MockHackerNewsApi)
        assert length(list) == 0
      end)

    assert log =~ "get a story: %{data: %{}, msg: \"bad input provided\"}"
    assert log =~ "Invalid data passed to ResponseParser"
  end

  test " success: http fail, get emtpy list" do
    HackerAggregator.MockHackerNewsApi
    |> expect(:fetch_top_stories, 1, fn ->
      {:error, "failed"}
    end)

    HackerAggregator.MockHackerNewsApi
    |> expect(:fetch_story, 0, fn _ -> nil end)

    log =
      capture_log([level: :error], fn ->
        list = HackerAggregator.get_list(12, HackerAggregator.MockHackerNewsApi)
        assert list == []
      end)

    assert log =~ "fetching list of stories failed: \"failed\""
  end

  @tag :real_api
  test "[real_api] success: pass N number, get N stories" do
    num = Enum.random(1..10)
    list = HackerAggregator.get_list(num, HackerAggregator.Boundary.HackerNewsApi)
    assert length(list) == num
  end

  @tag :real_api
  test "[real_api] success:  pass 1, get 1 valid story struct" do
    [story] = HackerAggregator.get_list(1, HackerAggregator.Boundary.HackerNewsApi)

    assert %Story{by: _, id: _, title: _, text: _, url: _} = story
  end

  @tag :pending
  test "success: get every second story an empty one, returns list of stories of half size length" do
    {:ok, list_of_stories_is} = fetch_top_stories_mock()

    HackerAggregator.MockHackerNewsApi
    |> expect(:fetch_top_stories, 1, fn ->
      {:ok, list_of_stories_is}
    end)

    HackerAggregator.MockHackerNewsApi
    |> expect(:fetch_story, length(list_of_stories_is), fn _ -> %{} end)
  end

  defp fetch_top_stories_mock() do
    list =
      File.read!("test/support/top_stories_list.json")
      |> Jason.decode!()

    {:ok, list}
  end
end
