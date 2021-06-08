defmodule HackerAggregator.Core.HackerNewsApi.ResponseParserTest do
  use ExUnit.Case, async: true
  alias HackerAggregator.Core.HackerNewsApi.ResponseParser
  alias HackerAggregator.Core.Story

  describe "parse_story/1" do
    setup do
      [url_response, text_response] =
        [
          "test/support/url_story_response.json",
          "test/support/text_story_response.json"
        ]
        |> Enum.map(fn path ->
          File.read!(path)
          |> Jason.decode!()
        end)

      incomplete_story = %Story{by: "by", id: 123, title: "title"}

      %{
        url_story: {:ok, url_response},
        text_story: {:ok, text_response},
        incomplete_story: {:ok, incomplete_story},
        bad_text_type_story: {:ok, Map.put(text_response, "type", "bad type")},
        error_response: {:error, %{}}
      }
    end

    test "success: accept a valid response, returns properly filled url Story struct",
         %{
           url_story: response
         } do
      assert {:ok, story} = ResponseParser.parse_story(response)

      assert %Story{
               by: "SerCe",
               id: 27_390_512,
               title: "An Unbelievable Demo",
               url: "https://brendangregg.com/blog/2021-06-04/an-unbelievable-demo.html"
             } = story
    end

    test "success: accept a valid response, returns properly filled text Story struct",
         %{
           text_story: response
         } do
      assert {:ok, story} = ResponseParser.parse_story(response)

      assert %Story{
               by: "MaxHoppersGhost",
               id: 27_394_925,
               title: "Ask HN: Tank man” image search blocked on Bing and DuckDuckGo",
               text:
                 "If you google “tank man” and click on images in Bing and DDG either nothing shows up (Bing) or unrelated photos shows up (DDG). Images show up in Google.<p>What does HN make of this? I would think that Bing&#x2F;DDG would have separate search results in China so I’m quite surprised to see this happening outside of China."
             } = story
    end

    test "error: forward a incomplete story, returns error tuple",
         %{
           incomplete_story: {:ok, story} = response
         } do
      assert {:error, %{msg: "invalid argument", data: ^story}} =
               ResponseParser.parse_story(response)
    end

    test "error: forward a bad type of story, returns error tuple",
         %{
           bad_text_type_story: {:ok, bad_text_type_story} = response
         } do
      assert {:error, %{msg: "story has no all required keys", data: ^bad_text_type_story}} =
               ResponseParser.parse_story(response)
    end

    test "error: forward a error response, returns error tuple",
         %{
           error_response: response
         } do
      assert {:error, %{msg: "bad input provided", data: ^response}} =
               ResponseParser.parse_story(response)
    end
  end
end
