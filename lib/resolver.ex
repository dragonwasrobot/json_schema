defmodule JsonSchema.Resolver do
  @moduledoc """
  Module containing functions for resolving types. Main function being
  the `resolve_type` function.
  """

  alias JsonSchema.{Parser, Types}
  alias Parser.{ErrorUtil, ParserError}
  alias Types.{PrimitiveType, SchemaDefinition, TypeReference}

  @doc ~S"""
  Resolves a type given its `identifier`, `parent` identifier of the resolving
  subschema, the subschema's enclosing `SchemaDefinition` and the schema
  dictionary of the whole set of parsed JSON schema files.

      {
        "$schema": "http://json-schema.org/draft-07/schema#",
        "$id": "http://example.com/circle.json",
        "title": "Circle",
        "description": "Schema for a circle shape",
        "type": "object",
        "properties": {
          "radius": {
            "type": "number"
          },
          "center": {
            "$ref": "http://example.com/definitions.json#point"
          },
          "color": {
            "$ref": "http://example.com/definitions.json#color"
          }
        },
        "required": ["center", "radius"]
      }
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
    resolved_result =
      cond do
        identifier in ["string", "number", "integer", "boolean"] ->
          primitive_type = %PrimitiveType{
            name: identifier,
            path: identifier,
            type: identifier
          }

          {:ok, {primitive_type, schema_def}}

        URI.parse(identifier).scheme == nil ->
          resolve_uri_fragment_identifier(
            URI.parse(identifier),
            URI.parse(parent),
            schema_def
          )

        URI.parse(identifier).scheme != nil ->
          resolve_fully_qualified_uri_identifier(
            URI.parse(identifier),
            URI.parse(parent),
            schema_dict
          )

        true ->
          error = ErrorUtil.unresolved_reference(URI.parse(identifier), URI.parse(parent))
          {:error, error}
      end

    case resolved_result do
      {:ok, {resolved_type, resolved_schema_def}} ->
        case resolved_type do
          %TypeReference{} ->
            resolve_type(
              resolved_type.path,
              parent,
              resolved_schema_def,
              schema_dict
            )

          _ ->
            {:ok, {resolved_type, resolved_schema_def}}
        end

      {:error, error} ->
        {:error, error}
    end
  end

  @spec resolve_uri_fragment_identifier(
          URI.t(),
          URI.t(),
          SchemaDefinition.t()
        ) ::
          {:ok, {Types.typeDefinition(), SchemaDefinition.t()}}
          | {:error, ParserError.t()}
  defp resolve_uri_fragment_identifier(identifier, parent, schema_def) do
    type_dict = schema_def.types
    resolved_type = type_dict[to_string(identifier)]

    if resolved_type != nil do
      {:ok, {resolved_type, schema_def}}
    else
      {:error, ErrorUtil.unresolved_reference(identifier, parent)}
    end
  end

  @spec resolve_fully_qualified_uri_identifier(
          URI.t(),
          URI.t(),
          Types.schemaDictionary()
        ) ::
          {:ok, {Types.typeDefinition(), SchemaDefinition.t()}}
          | {:error, ParserError.t()}
  defp resolve_fully_qualified_uri_identifier(identifier, parent, schema_dict) do
    schema_id = determine_schema_id(identifier)
    schema_def = schema_dict[schema_id]

    if schema_def != nil do
      type_dict = schema_def.types

      resolved_type =
        cond do
          to_string(identifier) == schema_id ->
            type_dict["#"]

          type_dict[to_string(identifier)] != nil ->
            type_dict[to_string(identifier)]

          true ->
            type_dict["##{identifier.fragment}"]
        end

      if resolved_type != nil do
        {:ok, {resolved_type, schema_def}}
      else
        {:error, ErrorUtil.unresolved_reference(identifier, parent)}
      end
    else
      {:error, ErrorUtil.unresolved_reference(identifier, parent)}
    end
  end

  @spec determine_schema_id(URI.t()) :: String.t()
  defp determine_schema_id(identifier) do
    identifier
    |> Map.put(:fragment, nil)
    |> to_string
  end
end
