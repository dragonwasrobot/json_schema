defmodule JsonSchema.Types do
  @moduledoc """
  Specifies the main Elixir types used for describing the
  intermediate representations of JSON schema types.
  """

  alias JsonSchema.Types

  alias Types.{
    AllOfType,
    AnyOfType,
    ArrayType,
    ConstType,
    EnumType,
    ObjectType,
    OneOfType,
    PrimitiveType,
    SchemaDefinition,
    TupleType,
    TypeReference,
    UnionType
  }

  @type typeDefinition ::
          AllOfType.t()
          | AnyOfType.t()
          | ArrayType.t()
          | ConstType.t()
          | EnumType.t()
          | ObjectType.t()
          | OneOfType.t()
          | PrimitiveType.t()
          | TupleType.t()
          | TypeReference.t()
          | UnionType.t()

  # Note: while all type identifiers are URIs, their fragments may be either
  # plain names, used for referencing named subschemas, or JSON pointers, used
  # for pointing down into the document at a specific subschema. See
  # https://datatracker.ietf.org/doc/html/draft-handrews-json-schema-01#section-5
  #
  # The reason a type identifier *can* also be a String is because
  # PrimitiveTypes are currently identified in a similar way to the other types,
  # which should ideally be changed.
  @type typeIdentifier :: URI.t() | String.t()

  @type json_value :: nil | boolean | map | list | integer | number | String.t()
  @type schemaNode :: %{required(String.t()) => json_value}
  @type propertyDictionary :: %{required(String.t()) => typeIdentifier}

  # Keys should be URI in these below
  @type typeDictionary :: %{required(String.t()) => typeDefinition}
  @type schemaDictionary :: %{required(String.t()) => SchemaDefinition.t()}

  defmodule SchemaDefinition do
    @moduledoc """
    An intermediate representation of the root of a whole JSON schema document.
    """

    alias JsonSchema.Types
    use TypedStruct

    typedstruct do
      field :file_path, Path.t(), enforce: true
      field :id, URI.t(), enforce: true
      field :title, String.t(), enforce: true
      field :description, String.t(), enforce: nil
      field :types, Types.typeDictionary(), enforce: true
    end
  end
end
