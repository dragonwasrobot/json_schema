defmodule JsonSchema.Types.EnumType do
  @moduledoc ~S"""
  Represents a custom `enum` type definition in a JSON schema.

  JSON Schema:

      "color": {
        "description": "A set of colors",
        "type": "string",
        "enum": ["none", "green", "orange", "blue", "yellow", "red"]
      }

  Resulting in the Elixir representation:

      %EnumType{name: "color",
                description: "A set of colors",
                path: URI.parse("#/color"),
                type: "string",
                values: ["none", "green", "orange",
                         "blue", "yellow", "red"]}
  """

  use TypedStruct

  @type value_type :: :integer | :number | :string

  typedstruct do
    field :name, String.t() | :anonymous, enforce: true
    field :description, String.t() | nil, default: nil
    field :path, URI.t(), enforce: true
    field :type, value_type() | nil, default: nil
    field :values, [String.t() | number | nil], enforce: true
  end
end
