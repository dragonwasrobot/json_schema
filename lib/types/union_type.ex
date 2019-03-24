defmodule JsonSchema.Types.UnionType do
  @moduledoc """
  Represents a custom `union` type definition in a JSON schema.

  JSON Schema:

      "favoriteNumber": {
        "type": ["number", "integer", "null"]
      }

  Resulting in the Elixir representation:

      %UnionType{name: "favoriteNumber",
                 path: URI.parse("#/favoriteNumber"),
                 types: ["number", "integer", "null"]}
  """

  @type t :: %__MODULE__{
          name: String.t(),
          path: URI.t(),
          types: [String.t()]
        }

  defstruct [:name, :path, :types]

  @spec new(String.t(), URI.t(), [String.t()]) :: t
  def new(name, path, types) do
    %__MODULE__{name: name, path: path, types: types}
  end
end
