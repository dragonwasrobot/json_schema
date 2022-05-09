defmodule JsonSchema.Types.AnyOfType do
  @moduledoc ~S"""
  Represents a custom `anyOf` type definition in a JSON schema.

  JSON Schema:

  The following example schema has the path `"#/definitions/fancyCircle"`

      {
        "description": "A fancy circle",
        "anyOf": [
          {
            "type": "object",
            "properties": {
              "color": {
                "$ref": "#/definitions/color"
              },
              "description": {
                "type": "string"
              }
            },
            "required": [ "color" ]
          },
          {
            "$ref": "#/definitions/circle"
          }
        ]
      }

  where `"#/definitions/color"` resolves to:

      {
        "type": "string",
        "enum": ["red", "yellow", "green"]
      }

  and `"#/definitions/circle"` resolves to:

      {
         "type": "object",
         "properties": {
           "radius": {
             "type": "number"
           }
         },
         "required": [ "radius" ]
      }

  Resulting in the Elixir representation:

      %AnyOfType{name: "fancyCircle",
                 description: "A fancy circle",
                 path: URI.parse("#/definitions/fancyCircle"),
                 types: [URI.parse("#/definitions/fancyCircle/allOf/0"),
                         URI.parse("#/definitions/fancyCircle/allOf/1")]}
  """

  use TypedStruct

  typedstruct do
    field :name, String.t() | :anonymous, enforce: true
    field :description, String.t() | nil, default: nil
    field :path, URI.t(), enforce: true
    field :types, [URI.t()], enforce: true
  end
end
