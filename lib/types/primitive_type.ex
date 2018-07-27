defmodule JsonSchema.Types.PrimitiveType do
  @moduledoc ~S"""
  Represents a custom 'primitive' type definition in a JSON schema.

  JSON Schema:

      "name": {
          "type": "string"
      }

  Resulting Elixir intermediate representation:

      %PrimitiveType{name: "name",
                     path: ["#", "name"],
                     type: "string"}
  """

  alias JsonSchema.TypePath

  @type t :: %__MODULE__{
          name: String.t(),
          path: String.t() | TypePath.t(),
          type: String.t()
        }

  defstruct [:name, :path, :type]

  @spec new(String.t(), String.t() | TypePath.t(), String.t()) :: t
  def new(name, path, type) do
    %__MODULE__{name: name, path: path, type: type}
  end
end
