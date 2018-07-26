defmodule JsonSchema.Parser.TypeReferenceParser do
  @behaviour JsonSchema.Parser.ParserBehaviour
  @moduledoc ~S"""
  Parses a JSON schema type reference:

      {
        "$ref": "#/definitions/link"
      }

  Into an `JsonSchema.Types.TypeReference`.
  """

  require Logger
  alias JsonSchema.{Parser, TypePath, Types}
  alias Parser.{ParserResult, Util}
  alias Types.TypeReference

  @doc ~S"""
  Returns true if the json subschema represents a reference to another schema.

  ## Examples

  iex> type?(%{})
  false

  iex> type?(%{"$ref" => "#foo"})
  true

  """
  @impl JsonSchema.Parser.ParserBehaviour
  @spec type?(map) :: boolean
  def type?(%{"$ref" => ref}) when is_binary(ref), do: true
  def type?(_schema_node), do: false

  @doc ~S"""
  Parses a JSON schema type reference into an `JsonSchema.Types.TypeReference`.
  """
  @impl JsonSchema.Parser.ParserBehaviour
  @spec parse(map, URI.t(), URI.t() | nil, TypePath.t(), String.t()) ::
          ParserResult.t()
  def parse(%{"$ref" => ref}, _parent_id, id, path, name) do
    ref_path = ref |> to_type_identifier

    type_reference = TypeReference.new(name, ref_path)

    type_reference
    |> Util.create_type_dict(path, id)
    |> ParserResult.new()
  end

  @spec to_type_identifier(String.t()) :: Types.typeIdentifier()
  defp to_type_identifier(path) do
    if URI.parse(path).scheme != nil do
      path |> URI.parse() |> to_string
    else
      path |> TypePath.from_string()
    end
  end
end
