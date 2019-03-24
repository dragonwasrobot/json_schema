defmodule JsonSchema.Types.ObjectType do
  @moduledoc """
  Represents a custom `object` type definition in a JSON schema.

  JSON Schema:

      "circle": {
        "type": "object",
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

  @type t :: %__MODULE__{
          name: String.t(),
          path: URI.t(),
          properties: Types.propertyDictionary(),
          pattern_properties: Types.propertyDictionary(),
          additional_properties: URI.t() | nil,
          required: [String.t()]
        }

  defstruct [:name, :path, :properties, :pattern_properties, :additional_properties, :required]

  @spec new(
          String.t(),
          URI.t(),
          Types.propertyDictionary(),
          Types.propertyDictionary(),
          URI.t() | nil,
          [String.t()]
        ) :: t
  def new(name, path, properties, pattern_properties, additional_properties, required) do
    %__MODULE__{
      name: name,
      path: path,
      properties: properties,
      pattern_properties: pattern_properties,
      additional_properties: additional_properties,
      required: required
    }
  end
end
