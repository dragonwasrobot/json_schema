defmodule JsonSchema.Types.UnionType do
  @moduledoc ~S"""
  Represents a custom `union` type definition in a JSON schema.

  JSON Schema:

      "favoriteNumber": {
        "description": "Your favorite number",
        "type": ["number", "integer", "null"]
      }

  Resulting in the Elixir representation:

      %UnionType{name: "favoriteNumber",
                 description: "Your favorite number",
                 path: URI.parse("#/favoriteNumber"),
                 types: [:number, :integer, :null]}
  """

  use TypedStruct

  @type value_type :: :null | :boolean | :integer | :number | :string

  typedstruct do
    field :name, String.t() | :anonymous, enforce: true
    field :description, String.t() | nil, default: nil
    field :path, URI.t(), enforce: true
    field :types, [value_type()], enforce: true
  end
end
