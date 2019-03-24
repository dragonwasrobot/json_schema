defmodule JsonSchema.Types.TypeReference do
  @moduledoc """
  Represents a reference to a custom type definition in a JSON schema.

  JSON Schema:

      "self": {
        "$ref": "#/definitions/foo"
      }

      "other": {
        "$ref": "http://www.example.com/definitions.json#bar"
      }

  where "#/definitions/foo" resolves to

      "definitions": {
        "foo": {
          "type": "string"
        }
      }

  and "http://www.example.com/definitions.json#bar" resolves to

      "definitions": {
        "bar": {
          "id": "#bar",
          "type": "number"
        }
      }

  Resulting in the Elixir representation:

      %TypeReference{name: "self",
                     path: URI.parse("#/definitions/foo"]}

      %TypeReference{name: "other",
                     path: URI.parse("http://www.example.com/definitions.json#bar")}

  """

  alias JsonSchema.Types

  @type t :: %__MODULE__{name: String.t(), path: Types.typeIdentifier()}

  defstruct [:name, :path]

  @spec new(String.t(), Types.typeIdentifier()) :: t
  def new(name, path) do
    %__MODULE__{name: name, path: path}
  end
end
