defmodule JsonSchema.Parser.ArrayParser do
  @behaviour JsonSchema.Parser.ParserBehaviour
  @moduledoc """
  Parses a JSON schema array type:

      {
        "type": "array",
        "items": {
          "$ref": "#/definitions/rectangle"
        }
      }

  Into an `JsonSchema.Types.ArrayType`.
  """

  require Logger

  alias JsonSchema.{Parser, Types}
  alias Parser.{ParserResult, Util}
  alias Types.ArrayType

  @doc """
  Returns true if the json subschema represents an array type.

  ## Examples

  iex> type?(%{})
  false

  iex> type?(%{"items" => %{"$ref" => "#foo"}})
  true
  """
  @impl JsonSchema.Parser.ParserBehaviour
  @spec type?(Types.schemaNode()) :: boolean
  def type?(schema_node) do
    items = schema_node["items"]
    is_map(items)
  end

  @doc """
  Parses a JSON schema array type into an `JsonSchema.Types.ArrayType`.
  """
  @impl JsonSchema.Parser.ParserBehaviour
  @spec parse(
          Types.schemaNode(),
          URI.t(),
          URI.t() | nil,
          URI.t(),
          String.t()
        ) :: ParserResult.t()
  def parse(%{"items" => items} = schema_node, parent_id, id, path, name) do
    description = Map.get(schema_node, "description")

    items_abs_path =
      path
      |> Util.add_fragment_child("items")

    items_result =
      items
      |> Util.parse_type(parent_id, path, "items")

    array_type = %ArrayType{
      name: name,
      description: description,
      path: path,
      items: items_abs_path
    }

    array_type
    |> Util.create_type_dict(path, id)
    |> ParserResult.new()
    |> ParserResult.merge(items_result)
  end
end
