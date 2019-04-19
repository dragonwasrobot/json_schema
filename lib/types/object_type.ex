defmodule JsonSchema.Types.ObjectType do
  @moduledoc """
  Represents a custom `object` type definition in a JSON schema.

  JSON Schema:

      "circle": {
        "type": "object",
        "description": "A circle object",
        "properties": {
          "color": {
            "$ref": "#/color"
          },
          "title": {
            "type": "string"
          },
          "radius": {
            "type": "number"
          }
        },
        "patternProperties": {
          "f.*o": {
            "type": "integer"
          }
        },
        "additionalProperties": {
          "type": "boolean"
        },
        "required": [ "color", "radius" ]
      }

  Resulting in the Elixir representation:

      %ObjectType{name: "circle",
                  description: "A circle object",
                  path: URI.parse("#/circle"),
                  required: ["color", "radius"],
                  properties: %{
                      "color" => URI.parse("#/circle/properties/color"),
                      "title" => URI.parse("#/circle/properties/title"),
                      "radius" => URI.parse("#/circle/properties/radius")},
                  pattern_properties: %{
                      "f.*o" => URI.parse("#/circle/patternProperties/f.*o")},
                  additional_properties: URI.parse("#/circle/additionalProperties")
  """

  alias JsonSchema.Types
  use TypedStruct

  typedstruct do
    field :name, String.t(), enforce: true
    field :description, String.t(), default: nil
    field :path, URI.t(), enforce: true
    field :properties, Types.propertyDictionary(), enforce: true
    field :pattern_properties, Types.propertyDictionary(), enforce: true
    field :additional_properties, URI.t(), default: nil
    field :required, [String.t()], default: []
  end
end
