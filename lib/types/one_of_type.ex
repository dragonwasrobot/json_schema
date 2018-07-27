defmodule JsonSchema.Types.OneOfType do
  @moduledoc ~S"""
  Represents a custom 'one_of' type definition in a JSON schema.

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

  Resulting Elixir intermediate representation:

      %OneOfType{name: "shape",
                 path: ["#", "shape"],
                 types: [["#", "shape", "oneOf", "0"],
                         ["#", "shape", "oneOf", "1"]]}
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
