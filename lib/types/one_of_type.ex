defmodule JsonSchema.Types.OneOfType do
  @moduledoc ~S"""
  Represents a custom `oneOf` type definition in a JSON schema.

  JSON Schema:

      "shape": {
        "description": "A union type of shapes",
        "oneOf": [
          {
            "$ref": "#/definitions/circle"
          },
          {
            "$ref": "#/definitions/rectangle"
          }
        ]
      }

  Resulting in the Elixir representation:

      %OneOfType{name: "shape",
                 description: "A union type of shapes",
                 path: URI.parse("#/shape"),
                 types: [URI.parse("#/shape/oneOf/0"),
                         URI.parse("#/shape/oneOf/1")]}
  """

  use TypedStruct

  typedstruct do
    field :name, String.t() | :anonymous, enforce: true
    field :description, String.t() | nil, default: nil
    field :path, URI.t(), enforce: true
    field :types, [URI.t()], enforce: true
  end
end
