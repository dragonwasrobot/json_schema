defmodule JsonSchema.Types.AnyOfType do
  @moduledoc """
  Represents a custom `anyOf` type definition in a JSON schema.

  JSON Schema:

  The following example schema has the path `"#/definitions/fancyCircle"`

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
                 path: URI.parse("#/definitions/fancyCircle"),
                 types: [URI.parse("#/definitions/fancyCircle/allOf/0"),
                         URI.parse("#/definitions/fancyCircle/allOf/1")]}
  """

  @type t :: %__MODULE__{
          name: String.t(),
          path: URI.t(),
          types: [URI.t()]
        }

  defstruct [:name, :path, :types]

  @spec new(String.t(), URI.t(), [URI.t()]) :: t
  def new(name, path, types) do
    %__MODULE__{name: name, path: path, types: types}
  end
end
