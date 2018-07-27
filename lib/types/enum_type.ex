defmodule JsonSchema.Types.EnumType do
  @moduledoc ~S"""
  Represents a custom 'enum' type definition in a JSON schema.

  JSON Schema:

      "color": {
        "type": "string",
        "enum": ["none", "green", "orange", "blue", "yellow", "red"]
      }

  Resulting Elixir intermediate representation:

      %EnumType{name: "color",
                path: ["#", "color"],
                type: "string",
                values: ["none", "green", "orange",
                         "blue", "yellow", "red"]}
  """

  alias JsonSchema.TypePath

  @type t :: %__MODULE__{
          name: String.t(),
          path: TypePath.t(),
          type: String.t(),
          values: [String.t() | number]
        }

  defstruct [:name, :path, :type, :values]

  @spec new(String.t(), TypePath.t(), String.t(), [String.t() | number]) :: t
  def new(name, path, type, values) do
    %__MODULE__{name: name, path: path, type: type, values: values}
  end
end
