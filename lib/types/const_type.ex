defmodule JsonSchema.Types.ConstType do
  @moduledoc """
  Represents a custom `const` type definition in a JSON schema.

  JSON Schema:

  "favoriteNumber": {
    "type": "integer",
    "const": 42
  }

  or

  "testStruct": {
    "const": {
      "name": "Test",
      "foo": 43
    }
  }

  Resulting in the Elixir representation:

  %ConstType{name: "favoriteNumber",
             description: nil,
             type: "number",
             path: URI.parse("#/favoriteNumber"),
             const: 42}

  or

  %ConstType{name: "testStruct",
             description: nil,
             type: "object",
             path: URI.parse("#/testStruct"),
             const: %{"name" => "Test", "foo" => 43}}
  """

  use TypedStruct

  typedstruct do
    field :name, String.t(), enforce: true
    field :description, String.t() | nil, default: nil
    field :path, URI.t(), enforce: true
    field :type, String.t() | nil, default: nil
    field :const, [map | list | String.t() | number | nil], enforce: true
  end
end
