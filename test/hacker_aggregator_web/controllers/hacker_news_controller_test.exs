defmodule HackerAggregatorWeb.HackerNewsControllerTest do
  use HackerAggregatorWeb.ConnCase

  import Mox

  alias HackerAggregator.Boundary.StoryServer
  # TODO: try to get rid of sleep from tests

  @valid_response %{
    "error" => "",
    "overall_pages" => 1,
    "page_number" => 1,
    "page_size" => 10,
    "stories" => [
      %{
        "by" => "SerCe",
        "id" => 27_390_512,
        "text" => nil,
        "title" => "An Unbelievable Demo",
        "url" => "https://brendangregg.com/blog/2021-06-04/an-unbelievable-demo.html"
      }
    ]
  }

  @page_too_big_response %{
    "error" => "Invalid page_number: 2 > 1",
    "overall_pages" => 1,
    "page_number" => 2,
    "page_size" => 10,
    "stories" => []
  }

  @page_too_low_response %{
    "error" => "Invalid page_number: -1 < 1",
    "overall_pages" => 1,
    "page_number" => -1,
    "page_size" => 10,
    "stories" => []
  }

  @raw_story %{
    "by" => "SerCe",
    "id" => 27_390_512,
    "text" => nil,
    "title" => "An Unbelievable Demo",
    "url" => "https://brendangregg.com/blog/2021-06-04/an-unbelievable-demo.html"
  }

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

    :ok
  end

  describe "index" do
    test "success: get first page with one story, get 200 - valid response with serialized %Pagination{}",
         %{
           conn: conn
         } do
      start_supervised!({StoryServer, []})
      Process.sleep(500)
      conn = get(conn, Routes.hacker_news_path(conn, :index, 1))
      assert json_response(conn, 200) == @valid_response
    end

    test "pass page value greater than overall pages number, get 404 and serialized %Pagination{} with error ",
         %{conn: conn} do
      start_supervised!({StoryServer, []})
      Process.sleep(500)
      conn = get(conn, Routes.hacker_news_path(conn, :index, 2))
      assert json_response(conn, 404) == @page_too_big_response
    end

    test "pass page as negative number, get 404 and serialized %Pagination{} with error", %{
      conn: conn
    } do
      start_supervised!({StoryServer, []})
      Process.sleep(500)
      conn = get(conn, Routes.hacker_news_path(conn, :index, -1))
      assert json_response(conn, 404) == @page_too_low_response
    end

    test "pass page as invalid string, get 400 and Bad Request msg", %{
      conn: conn
    } do
      start_supervised!({StoryServer, []})
      Process.sleep(500)
      conn = get(conn, Routes.hacker_news_path(conn, :index, "invalid page"))
      assert json_response(conn, 400) == "Bad Request"
    end

    test "pass page as string with characters and numbres, get 400 and Bad Request msg", %{
      conn: conn
    } do
      start_supervised!({StoryServer, []})
      Process.sleep(500)
      conn = get(conn, Routes.hacker_news_path(conn, :index, "123invalid"))
      assert json_response(conn, 400) == "Bad Request"
    end

    @tag :pending
    test "when server has no any stories , get 503 and \"No stories available now\" msg", %{
      conn: conn
    } do
      start_supervised!({StoryServer, []})
      conn = get(conn, Routes.hacker_news_path(conn, :index, 123))
      assert json_response(conn, 503) =~ "No stories available now"
    end
  end

  describe "show" do
    test "get 200 and story", %{
      conn: conn
    } do
      start_supervised!({StoryServer, []})
      Process.sleep(500)
      conn = get(conn, Routes.hacker_news_path(conn, :show, @raw_story["id"]))
      assert json_response(conn, 200) == @raw_story
    end

    test "pass bad id, get 404 and Not Found", %{
      conn: conn
    } do
      start_supervised!({StoryServer, []})
      Process.sleep(500)
      conn = get(conn, Routes.hacker_news_path(conn, :show, 0_000_000))
      assert json_response(conn, 404) == "Not Found"
    end

    test "pass invalid id type, get 400 and Bad Request", %{
      conn: conn
    } do
      start_supervised!({StoryServer, []})
      Process.sleep(500)
      conn = get(conn, Routes.hacker_news_path(conn, :show, "bad value"))
      assert json_response(conn, 400) == "Bad Request"
    end
  end
end
