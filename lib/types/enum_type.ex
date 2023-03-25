defmodule JsonSchema.Types.EnumType do
  @moduledoc ~S"""
  Represents a custom `enum` type definition in a JSON schema.

  JSON Schema:

      "color": {
        "description": "A set of colors",
        "default": "green",
        "type": "string",
        "enum": ["none", "green", "orange", "blue", "yellow", "red"]
      }

  Resulting in the Elixir representation:

      %EnumType{name: "color",
                description: "A set of colors",
                "default": "green",
                path: URI.parse("#/color"),
                type: "string",
                values: ["none", "green", "orange",
                         "blue", "yellow", "red"]}
  """

  use TypedStruct

  @type value_type :: String.t() | number() | integer()
  @type value_type_name :: :integer | :number | :string

  typedstruct do
    field :name, String.t() | :anonymous, enforce: true
    field :description, String.t() | nil, default: nil
    field :default, value_type() | nil, default: nil
    field :path, URI.t(), enforce: true
    field :type, value_type_name() | nil, default: nil
    field :values, [value_type()], enforce: true
  end
end
