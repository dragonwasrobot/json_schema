defmodule JsonSchema.Parser do
  @moduledoc ~S"""
  Parses JSON schema files into an intermediate representation to be used for
  e.g. printing elm decoders.
  """

  require Logger
  alias JsonSchema.Parser.{RootParser, SchemaResult}

  @doc ~S"""
  Parses one or more JSON Schema files into a `SchemaResult`.
  """
  @spec parse_schema_files([Path.t()]) :: SchemaResult.t()
  def parse_schema_files(schema_paths) do
    schema_paths
    |> Enum.map(fn schema_path -> {schema_path, File.read!(schema_path)} end)
    |> parse_schema_documents()
  end

  @doc ~S"""
  Parses one or more JSON Schema documents into a `SchemaResult`.
  """
  @spec parse_schema_documents([{Path.t(), String.t()}]) :: SchemaResult.t()
  def parse_schema_documents(schema_path_document_pairs) do
    schema_path_document_pairs
    |> Enum.reduce(SchemaResult.new(), fn {schema_path, schema_document}, acc ->
      schema_document
      |> parse_schema_document(schema_path)
      |> SchemaResult.merge(acc)
    end)
  end

  @doc ~S"""
  Parses a single JSON Schema documents into a `SchemaResult`.
  """
  @spec parse_schema_document(String.t(), Path.t()) :: SchemaResult.t()
  def parse_schema_document(schema_document, schema_path) do
    schema_document
    |> Poison.decode!()
    |> RootParser.parse_schema(schema_path)
  end
end
