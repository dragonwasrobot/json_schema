defmodule JsonSchema.Types.SchemaDefinition do
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
