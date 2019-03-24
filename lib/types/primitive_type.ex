defmodule JsonSchema.Types.PrimitiveType do
  @moduledoc """
  Represents a custom `primitive` type definition in a JSON schema.

  JSON Schema:

      "name": {
          "type": "string"
      }

  Resulting in the Elixir representation:

      %PrimitiveType{name: "name",
                     path: URI.parse("#/name"),
                     type: "string"}
  """

  @type t :: %__MODULE__{
          name: String.t(),
          path: String.t() | URI.t(),
          type: String.t()
        }

  defstruct [:name, :path, :type]

  @spec new(String.t(), String.t() | URI.t(), String.t()) :: t
  def new(name, path, type) do
    %__MODULE__{name: name, path: path, type: type}
  end
end
