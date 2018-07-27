defmodule JsonSchema.Types.TupleType do
  @moduledoc ~S"""
  Represents a custom 'tuple' type definition in a JSON schema.

  JSON Schema:

      "shapePair": {
        "type": "array",
        "items": [
          { "$ref": "#/rectangle" },
          { "$ref": "#/circle" }
        ]
      }

  Resulting Elixir intermediate representation:

      %TupleType{name: "shapePair",
                 path: ["#", "rectangles"],
                 items: [["#", "shapePair", "items", "0"],
                         ["#", "shapePair", "items", "1"]}
  """

  alias JsonSchema.TypePath

  @type t :: %__MODULE__{
          name: String.t(),
          path: TypePath.t(),
          items: TypePath.t()
        }

  defstruct [:name, :path, :items]

  @spec new(String.t(), TypePath.t(), TypePath.t()) :: t
  def new(name, path, items) do
    %__MODULE__{name: name, path: path, items: items}
  end
end
