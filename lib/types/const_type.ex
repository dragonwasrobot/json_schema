defmodule JsonSchema.Types.ConstType do
  @moduledoc ~S"""
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
                 type: :number,
                 path: URI.parse("#/favoriteNumber"),
                 const: 42}

  or

      %ConstType{name: "testStruct",
                 description: nil,
                 type: :object,
                 path: URI.parse("#/testStruct"),
                 const: %{"name" => "Test", "foo" => 43}}
  """

  use TypedStruct

  @type value_type ::
          :null | :boolean | :integer | :number | :string | :object | :array

  @type value :: nil | boolean | integer | number | String.t() | map | list

  typedstruct do
    field :name, String.t() | :anonymous, enforce: true
    field :description, String.t() | nil, default: nil
    field :path, URI.t(), enforce: true
    field :type, value_type, default: nil
    field :const, value, enforce: true
  end
end
