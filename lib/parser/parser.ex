defmodule JsonSchema.Parser do
  @moduledoc """
  Parses JSON schema files into an intermediate representation to be used for
  e.g. printing elm decoders.
  """

  require Logger
  alias JsonSchema.Parser.{ErrorUtil, RootParser, SchemaResult}

  @doc """
  Parses one or more JSON Schema files into a `SchemaResult`.
  """
  @spec parse_schema_files([Path.t()]) :: SchemaResult.t()
  def parse_schema_files(schema_paths) do
    {ok_schemas, failed_schemas} =
      schema_paths
      |> Enum.reduce({[], []}, fn schema_path, {schemas, failed_schemas} ->
        case File.read(schema_path) do
          {:ok, schema} ->
            {[{schema_path, schema} | schemas], failed_schemas}

          {:error, _posix} ->
            {schemas, [schema_path | failed_schemas]}
        end
      end)

    if Enum.empty?(failed_schemas) do
      parse_schema_documents(ok_schemas)
    else
      parser_errors =
        failed_schemas
        |> Enum.map(fn schema_path ->
          ErrorUtil.could_not_read_file(schema_path)
        end)

      SchemaResult.new(%{}, [], parser_errors)
    end
  end

  @doc """
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

  @doc """
  Parses a single JSON Schema documents into a `SchemaResult`.
  """
  @spec parse_schema_document(String.t(), Path.t()) :: SchemaResult.t()
  def parse_schema_document(schema_document, schema_path) do
    case Jason.decode(schema_document) do
      {:ok, json} ->
        RootParser.parse_schema(json, schema_path)

      {:error, error} ->
        decode_error =
          {schema_path, [ErrorUtil.invalid_json(schema_path, error)]}

        SchemaResult.new(%{}, [], [decode_error])
    end
  end
end
