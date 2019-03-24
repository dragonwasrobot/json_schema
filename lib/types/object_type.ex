defmodule JsonSchema.Types.ObjectType do
  @moduledoc ~S"""
  Represents a custom 'object' type definition in a JSON schema.

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

  Resulting Elixir intermediate representation:

      %ObjectType{name: "circle",
                  path: ["#", "circle"],
                  required: ["color", "radius"],
                  properties: %{
                      "color" => ["#", "circle", "properties", "color"],
                      "title" => ["#", "circle", "properties", "title"],
                      "radius" => ["#", "circle", "properties", "radius"]},
                  pattern_properties: %{
                      "f.*o" => ["#", "circle", "patternProperties", "f.*o"]},
                  additional_properties: ["#", "circle", "additionalProperties"]
  """

  alias JsonSchema.{TypePath, Types}

  @type t :: %__MODULE__{
          name: String.t(),
          path: TypePath.t(),
          properties: Types.propertyDictionary(),
          pattern_properties: Types.propertyDictionary(),
          additional_properties: TypePath.t() | nil,
          required: [String.t()]
        }

  defstruct [:name, :path, :properties, :pattern_properties, :additional_properties, :required]

  @spec new(
          String.t(),
          TypePath.t(),
          Types.propertyDictionary(),
          Types.propertyDictionary(),
          TypePath.t() | nil,
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
