defmodule JsonSchema.Types.TupleType do
  @moduledoc """
  Represents a custom `tuple` type definition in a JSON schema.

  JSON Schema:

      "shapePair": {
        "type": "array",
        "items": [
          { "$ref": "#/rectangle" },
          { "$ref": "#/circle" }
        ]
      }

  Resulting in the Elixir representation:

      %TupleType{name: "shapePair",
                 path: URI.parse("#/rectangles"),
                 items: [URI.parse("#/shapePair/items/0"],
                         URI.parse("#/shapePair/items/1"]}
  """

  @type t :: %__MODULE__{
          name: String.t(),
          path: URI.t(),
          items: [URI.t()]
        }

  defstruct [:name, :path, :items]

  @spec new(String.t(), URI.t(), [URI.t()]) :: t
  def new(name, path, items) do
    %__MODULE__{name: name, path: path, items: items}
  end
end
