defmodule HackerAggregator.Core.Story do
  @enforce_keys ~w/by id title/a
  defstruct ~w/by id title url text/a

  @type story_type :: %HackerAggregator.Core.Story{
          by: String.t(),
          id: integer(),
          title: String.t(),
          url: String.t() | nil,
          text: String.t() | nil
        }
end
