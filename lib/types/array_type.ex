defmodule JsonSchema.Types.ArrayType do
  @moduledoc ~S"""
  Represents a custom `array` type definition in a JSON schema.

  JSON Schema:

      "rectangles": {
        "description": "A list of rectangles",
        "type": "array",
        "items": {
          "$ref": "#/rectangle"
        }
      }

  Resulting in the Elixir representation:

      %ArrayType{name: "rectangles",
                 description: "A list of rectangles",
                 path: URI.parse("#/rectangles"),
                 items: URI.parse("#/rectangles/items")}
  """

  use TypedStruct

  typedstruct do
    field :name, String.t() | :anonymous, enforce: true
    field :description, String.t() | nil, default: nil
    field :path, URI.t(), enforce: true
    field :items, URI.t(), enforce: true
  end
end
