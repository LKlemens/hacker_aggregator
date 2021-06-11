defmodule HackerAggregator.Core.Story do
  @enforce_keys ~w/by id title/a
  defstruct ~w/by id title url text/a

  @type story_type :: %__MODULE__{
          by: String.t(),
          id: integer(),
          title: String.t(),
          url: String.t() | nil,
          text: String.t() | nil
        }

  defimpl Jason.Encoder, for: __MODULE__ do
    def encode(value, opts) do
      Jason.Encode.map(
        Map.take(value, [:by, :id, :title, :url, :text]),
        opts
      )
    end
  end
end
