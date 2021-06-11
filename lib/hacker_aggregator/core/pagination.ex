defmodule HackerAggregator.Core.Pagination do
  @enforce_keys [:stories, :page_size, :page_number, :overall_pages]
  defstruct ~w/stories page_size page_number overall_pages error/a

  @type pagination :: %HackerAggregator.Core.Pagination{
          stories: list(),
          page_size: integer(),
          page_number: integer(),
          overall_pages: integer(),
          error: String.t()
        }

  @spec new(stories :: [...], params :: keyword(integer())) :: %__MODULE__{}
  def new(stories, params \\ []) do
    page_number = Keyword.get(params, :page_number, 1)
    page_size = Keyword.get(params, :page_size, 10)
    total_pages = overall_pages(stories, page_size)

    %__MODULE__{
      stories: choose_stories(stories, page_size, page_number),
      page_size: page_size,
      page_number: page_number,
      overall_pages: total_pages,
      error: page_validation(page_number, total_pages)
    }
  end

  #
  ###########
  # PRIVATE
  ###########

  @spec choose_stories(stories :: [...], page_size :: integer(), page_number :: integer()) ::
          [
            ...
          ]
          | []
  defp choose_stories(stories, page_size, page_number)
       when is_number(page_number) and page_number > 0 do
    offset = page_size * (page_number - 1)

    stories
    |> Enum.slice(offset, page_size)
  end

  []

  defp choose_stories(_stories, _page_size, _page_number) do
    []
  end

  @spec overall_pages(stories :: [...], page_size :: integer()) :: integer()
  defp overall_pages(stories, page_size) do
    ceil(length(stories) / page_size)
  end

  @spec page_validation(page_number :: integer(), _total_pages :: integer()) :: String.t()
  defp page_validation(page_number, _total_pages) when page_number < 1 do
    "Invalid page_number: #{page_number} < 1"
  end

  defp page_validation(_page_number, total_pages) when total_pages == 0 do
    "No stories avaible now, please try again in a few moments"
  end

  defp page_validation(page_number, total_pages) when page_number > total_pages do
    "Invalid page_number: #{page_number} > #{total_pages}"
  end

  defp page_validation(_page_number, _total_pages) do
    ""
  end

  defimpl Jason.Encoder, for: __MODULE__ do
    def encode(value, opts) do
      Jason.Encode.map(
        Map.take(value, [:stories, :page_size, :page_number, :overall_pages, :error]),
        opts
      )
    end
  end
end
