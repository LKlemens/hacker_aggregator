defmodule HackerAggregatorWeb.StoriesChannelTest do
  use HackerAggregatorWeb.ChannelCase

  import Mox

  alias HackerAggregator.Boundary.StoryServer

  setup [:set_mox_from_context, :verify_on_exit!]

  setup do
    list_of_stories_ids =
      File.read!("test/support/top_stories_list.json")
      |> Jason.decode!()

    story =
      File.read!("test/support/url_story_response.json")
      |> Jason.decode!()

    HackerAggregator.MockHackerNewsApi
    |> stub(:fetch_top_stories, fn ->
      {:ok, list_of_stories_ids}
    end)

    HackerAggregator.MockHackerNewsApi
    |> stub(:fetch_story, fn _ ->
      {:ok, story}
    end)

    start_supervised!({StoryServer, []})
    Process.sleep(500)

    :ok
  end

  setup do
    {:ok, message, socket} =
      HackerAggregatorWeb.UserSocket
      |> socket("user_id", %{some: :assign})
      |> subscribe_and_join(HackerAggregatorWeb.StoriesChannel, "stories")

    assert message == [
             %HackerAggregator.Core.Story{
               by: "SerCe",
               id: 27_390_512,
               text: nil,
               title: "An Unbelievable Demo",
               url: "https://brendangregg.com/blog/2021-06-04/an-unbelievable-demo.html"
             }
           ]

    %{socket: socket}
  end

  test "new_story replies with status ok", %{socket: socket} do
    ref = push(socket, "new_story", %{"hello" => "there"})
    assert_reply(ref, :ok, %{"hello" => "there"})
  end
end
