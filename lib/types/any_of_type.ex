defmodule JsonSchema.Types.AnyOfType do
  @moduledoc ~S"""
  Represents a custom 'any_of' type definition in a JSON schema.

  JSON Schema:

  The following example schema has the path "#/definitions/fancyCircle"

      {
        "allOf": [
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

  Where "#/definitions/color" resolves to:

      {
        "type": "string",
        "enum": ["red", "yellow", "green"]
      }

  Where "#/definitions/circle" resolves to:

      {
         "type": "object",
         "properties": {
           "radius": {
             "type": "number"
           }
         },
         "required": [ "radius" ]
      }

  Resulting Elixir intermediate representation:

      %AnyOfType{name: "fancyCircle",
                 path: ["#", "definitions", "fancyCircle"],
                 types: [["#", "definitions", "fancyCircle", "allOf", "0"],
                         ["#", "definitions", "fancyCircle", "allOf", "1"]]}
  """

  alias JsonSchema.TypePath

  @type t :: %__MODULE__{
          name: String.t(),
          path: TypePath.t(),
          types: [TypePath.t()]
        }

  defstruct [:name, :path, :types]

  @spec new(String.t(), TypePath.t(), [TypePath.t()]) :: t
  def new(name, path, types) do
    %__MODULE__{name: name, path: path, types: types}
  end
end
