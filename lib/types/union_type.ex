defmodule JsonSchema.Types.UnionType do
  @moduledoc ~S"""
  Represents a custom 'union' type definition in a JSON schema.

  JSON Schema:

      "favoriteNumber": {
        "type": ["number", "integer", "null"]
      }

  Resulting Elixir intermediate representation:

      %UnionType{name: "favoriteNumber",
                 path: ["#", "favoriteNumber"],
                 types: ["number", "integer", "null"]}
  """

  alias JsonSchema.TypePath

  @type t :: %__MODULE__{
          name: String.t(),
          path: TypePath.t(),
          types: [String.t()]
        }

  defstruct [:name, :path, :types]

  @spec new(String.t(), TypePath.t(), [String.t()]) :: t
  def new(name, path, types) do
    %__MODULE__{name: name, path: path, types: types}
  end
end
