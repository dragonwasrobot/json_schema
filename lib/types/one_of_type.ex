defmodule JsonSchema.Types.OneOfType do
  @moduledoc """
  Represents a custom `oneOf` type definition in a JSON schema.

  JSON Schema:

      "shape": {
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
                 path: URI.parse("#/shape"),
                 types: [URI.parse("#/shape/oneOf/0"),
                         URI.parse("#/shape/oneOf/1")]}
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
