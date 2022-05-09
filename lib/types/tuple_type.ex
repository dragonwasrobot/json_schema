defmodule JsonSchema.Types.TupleType do
  @moduledoc ~S"""
  Represents a custom `tuple` type definition in a JSON schema.

  JSON Schema:

      "shapePair": {
        "description": "A choice of shape",
        "type": "array",
        "items": [
          { "$ref": "#/rectangle" },
          { "$ref": "#/circle" }
        ]
      }

  Resulting in the Elixir representation:

      %TupleType{name: "shapePair",
                 description: "A choice of shape",
                 path: URI.parse("#/rectangles"),
                 items: [URI.parse("#/shapePair/items/0"],
                         URI.parse("#/shapePair/items/1"]}
  """

  use TypedStruct

  typedstruct do
    field :name, String.t() | :anonymous, enforce: true
    field :description, String.t() | nil, default: nil
    field :path, URI.t(), enforce: true
    field :items, [URI.t()], enforce: true
  end
end
