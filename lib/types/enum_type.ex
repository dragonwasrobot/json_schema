defmodule JsonSchema.Types.EnumType do
  @moduledoc """
  Represents a custom `enum` type definition in a JSON schema.

  JSON Schema:

      "color": {
        "type": "string",
        "enum": ["none", "green", "orange", "blue", "yellow", "red"]
      }

  Resulting in the Elixir representation:

      %EnumType{name: "color",
                path: URI.parse("#/color"),
                type: "string",
                values: ["none", "green", "orange",
                         "blue", "yellow", "red"]}
  """

  @type t :: %__MODULE__{
          name: String.t(),
          path: URI.t(),
          type: String.t(),
          values: [String.t() | number]
        }

  defstruct [:name, :path, :type, :values]

  @spec new(String.t(), URI.t(), String.t(), [String.t() | number]) :: t
  def new(name, path, type, values) do
    %__MODULE__{name: name, path: path, type: type, values: values}
  end
end
