defmodule JsonSchema.Parser.TupleParser do
  @behaviour JsonSchema.Parser.ParserBehaviour
  @moduledoc """
  Parses a JSON schema array type:

      {
        "type": "array",
        "items": [
          { "$ref": "#/rectangle" },
          { "$ref": "#/circle" }
        ]
      }

  Into a `JsonSchema.Types.TupleType`.
  """

  require Logger

  alias JsonSchema.{Parser, Types}
  alias Parser.{ParserResult, Util}
  alias Types.TupleType

  @doc """
  Returns true if the json subschema represents a tuple type.

  ## Examples

  iex> type?(%{})
  false

  iex> aTuple = %{"items" => [%{"$ref" => "#foo"}, %{"$ref" => "#bar"}]}
  iex> type?(aTuple)
  true

  """
  @impl JsonSchema.Parser.ParserBehaviour
  @spec type?(Types.schemaNode()) :: boolean
  def type?(schema_node) do
    items = schema_node["items"]
    is_list(items)
  end

  @doc """
  Parses a JSON schema array type into an `JsonSchema.Types.TupleType`.
  """
  @impl JsonSchema.Parser.ParserBehaviour
  @spec parse(
          Types.schemaNode(),
          URI.t(),
          URI.t() | nil,
          URI.t(),
          String.t()
        ) :: ParserResult.t()
  def parse(%{"items" => items} = schema_node, parent_id, id, path, name)
      when is_list(items) do
    description = Map.get(schema_node, "description")
    child_path = Util.add_fragment_child(path, "items")

    child_types_result =
      items
      |> Util.parse_child_types(parent_id, child_path)

    tuple_types =
      child_types_result.type_dict
      |> Util.create_types_list(child_path)

    tuple_type = %TupleType{
      name: name,
      description: description,
      path: path,
      items: tuple_types
    }

    tuple_type
    |> Util.create_type_dict(path, id)
    |> ParserResult.new()
    |> ParserResult.merge(child_types_result)
  end
end
