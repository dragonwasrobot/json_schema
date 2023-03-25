defmodule JsonSchema.Parser.ArrayParser do
  @behaviour JsonSchema.Parser.ParserBehaviour
  @moduledoc ~S"""
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
  alias Parser.{ErrorUtil, ParserResult, Util}
  alias Types.ArrayType

  @doc ~S"""
  Returns true if the json subschema represents an array type.

  ## Examples

  iex> type?(%{})
  false

  iex> type?(%{"items" => %{"$ref" => "#foo"}})
  true
  """
  @impl JsonSchema.Parser.ParserBehaviour
  @spec type?(Types.schemaNode()) :: boolean
  def type?(%{"items" => items}) when is_map(items), do: true
  def type?(_schema_node), do: false

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
    default = Map.get(schema_node, "default")

    errors =
      if default != nil && not is_list(default) do
        [ErrorUtil.invalid_type(path, "default", "array", default)]
      else
        []
      end

    items_abs_path =
      path
      |> Util.add_fragment_child("items")

    items_result =
      items
      |> Util.parse_type(parent_id, items_abs_path, :anonymous)

    array_type = %ArrayType{
      name: name,
      description: description,
      default: default,
      path: path,
      items: items_abs_path
    }

    array_type
    |> Util.create_type_dict(path, id)
    |> ParserResult.new([], errors)
    |> ParserResult.merge(items_result)
  end
end
