defmodule JsonSchema.Types.PrimitiveType do
  @moduledoc ~S"""
  Represents a custom `primitive` type definition in a JSON schema.

  JSON Schema:

      "name": {
        "description": "A name",
        "type": "string"
      }

  Resulting in the Elixir representation:

      %PrimitiveType{name: "name",
                     description: "A name",
                     path: URI.parse("#/name"),
                     type: :string}
  """

  use TypedStruct

  @type value_type :: :null | :boolean | :integer | :number | :string

  typedstruct do
    field :name, String.t() | :anonymous, enforce: true
    field :description, String.t() | nil, default: nil
    field :path, URI.t(), enforce: true
    field :type, value_type, enforce: true
  end
end
