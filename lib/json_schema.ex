defmodule JsonSchema do
  @moduledoc File.read!("README.md")

  alias JsonSchema.{Parser, Resolver, Types}
  alias Parser.SchemaResult

  @doc ~S"""
  Parses one or more JSON schema files into a `SchemaResult` containing a
  dictionary of parsed schemas represented as Elixir structs and two lists of
  any warnings or errors encountered while parsing the JSON schema documents.
  """
  @spec parse_schema_files([Path.t()]) :: SchemaResult.t()
  def parse_schema_files(schema_paths) do
    Parser.parse_schema_files(schema_paths)
  end

  @doc ~S"""
  Parses one or more JSON Schema documents into a `SchemaResult`.
  """
  @spec parse_schema_documents([{Path.t(), String.t()}]) :: SchemaResult.t()
  def parse_schema_documents(schema_path_document_pairs) do
    Parser.parse_schema_documents(schema_path_document_pairs)
  end

  @doc ~S"""
  Parses a single JSON Schema documents into a `SchemaResult`.
  """
  @spec parse_schema_document(Path.t(), String.t()) :: SchemaResult.t()
  def parse_schema_document(schema_path, schema_document) do
    Parser.parse_schema_document(schema_document, schema_path)
  end

  @doc ~S"""
  Resolves a JSON schema `Types.typeIdentifier`, when given a `SchemaDefinition`
  and a `Types.schemaDictionary`.
  """
  @spec resolve_type(
          Types.typeIdentifier(),
          Types.typeIdentifier(),
          SchemaDefinition.t(),
          Types.schemaDictionary()
        ) ::
          {:ok, {Types.typeDefinition(), SchemaDefinition.t()}}
          | {:error, ParserError.t()}
  def resolve_type(identifier, parent, schema_def, schema_dict) do
    Resolver.resolve_type(identifier, parent, schema_def, schema_dict)
  end
end
