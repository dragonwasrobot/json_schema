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
                  patternProperties: %{
                      "f.*o" => ["#", "circle", "patternProperties", "f.*o"]}}
  """

  alias JsonSchema.{TypePath, Types}

  @type t :: %__MODULE__{
          name: String.t(),
          path: TypePath.t(),
          properties: Types.propertyDictionary(),
          patternProperties: Types.propertyDictionary(),
          required: [String.t()]
        }

  defstruct [:name, :path, :properties, :patternProperties, :required]

  @spec new(
          String.t(),
          TypePath.t(),
          Types.propertyDictionary(),
          Types.propertyDictionary(),
          [String.t()]
        ) :: t
  def new(name, path, properties, patternProperties, required) do
    %__MODULE__{
      name: name,
      path: path,
      properties: properties,
      patternProperties: patternProperties,
      required: required
    }
  end
end
