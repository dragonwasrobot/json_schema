defmodule JsonSchema.Parser.PrimitiveParser do
  @behaviour JsonSchema.Parser.ParserBehaviour
  @moduledoc """
  Parses a JSON schema primitive type:

      {
        "type": "string"
      }

  Into an `JsonSchema.Types.PrimitiveType`.
  """

  require Logger

  alias JsonSchema.{Parser, Types}
  alias Parser.{ParserResult, Util}
  alias Types.PrimitiveType

  @doc """
  Returns true if the json subschema represents a primitive type.

  ## Examples

  iex> type?(%{})
  false

  iex> type?(%{"type" => "object"})
  false

  iex> type?(%{"type" => "boolean"})
  true

  iex> type?(%{"type" => "integer"})
  true

  """
  @impl JsonSchema.Parser.ParserBehaviour
  @spec type?(map) :: boolean
  def type?(schema_node) do
    type = schema_node["type"]
    type in ["null", "boolean", "string", "number", "integer"]
  end

  @doc """
  Parses a JSON schema primitive type into an `JsonSchema.Types.PrimitiveType`.
  """
  @impl JsonSchema.Parser.ParserBehaviour
  @spec parse(map, URI.t(), URI.t(), URI.t(), String.t()) ::
          ParserResult.t()
  def parse(schema_node, _parent_id, id, path, name) do
    type = schema_node["type"]
    primitive_type = PrimitiveType.new(name, path, type)

    primitive_type
    |> Util.create_type_dict(path, id)
    |> ParserResult.new()
  end
end
