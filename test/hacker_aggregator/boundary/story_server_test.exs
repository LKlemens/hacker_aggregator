defmodule HackerAggregator.Boundary.StoryServerTest do
  use ExUnit.Case

  import Mox
  import ExUnit.CaptureLog

  alias HackerAggregator.Boundary.StoryServer
  alias HackerAggregator.Core.Story

  setup [:set_mox_from_context, :verify_on_exit!]

  setup do
    list_of_stories_ids =
      File.read!("test/support/top_stories_list.json")
      |> Jason.decode!()

    story =
      File.read!("test/support/url_story_response.json")
      |> Jason.decode!()

    %{list: list_of_stories_ids, story: story}
  end

  test "success: returns list of tuples with timestamp and stories after start", %{
    list: list_of_stories_ids,
    story: story
  } do
    HackerAggregator.MockHackerNewsApi
    |> expect(:fetch_top_stories, 1, fn ->
      {:ok, list_of_stories_ids}
    end)

    HackerAggregator.MockHackerNewsApi
    |> expect(:fetch_story, 50, fn _ ->
      {:ok, story}
    end)

    start_supervised!({StoryServer, []})
    Process.sleep(500)

    list = StoryServer.get_stories()
    assert length(list) == 1
    assert {_timeout, %Story{by: _, id: _, title: _, text: _, url: _}} = Enum.at(list, 0)

    capture_log([level: :warn], fn ->
      stop_supervised!(StoryServer)
    end)
  end

  test "success: it calls fetch_top_stories", %{
    list: list_of_stories_ids,
    story: story
  } do
    test_pid = self()
    ref = make_ref()

    HackerAggregator.MockHackerNewsApi
    |> expect(:fetch_top_stories, 1, fn ->
      send(test_pid, {:fetch_top_stories_called, ref})
      {:ok, list_of_stories_ids}
    end)

    HackerAggregator.MockHackerNewsApi
    |> stub(:fetch_story, fn _ ->
      {:ok, story}
    end)

    start_supervised!({StoryServer, []})

    assert_receive {:fetch_top_stories_called, ^ref}, 500

    capture_log([level: :warn], fn ->
      stop_supervised!(StoryServer)
    end)
  end

  test "success: it print warn msg when terminate", %{
    list: list_of_stories_ids,
    story: story
  } do
    HackerAggregator.MockHackerNewsApi
    |> expect(:fetch_top_stories, 1, fn ->
      {:ok, list_of_stories_ids}
    end)

    HackerAggregator.MockHackerNewsApi
    |> stub(:fetch_story, fn _ ->
      {:ok, story}
    end)

    start_supervised!({StoryServer, []})

    capture_log([level: :warn], fn ->
      stop_supervised!(StoryServer)
    end) =~ "terminated with reason: :shutdownn"
  end
end
