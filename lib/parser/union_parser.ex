defmodule JsonSchema.Parser.UnionParser do
  @behaviour JsonSchema.Parser.ParserBehaviour
  @moduledoc """
  Parses a JSON schema union type:

      {
        "type": ["number", "integer", "null"]
      }

  Into an `JsonSchema.Types.UnionType`.
  """

  require Logger
  alias JsonSchema.{Parser, Types}
  alias Parser.{ErrorUtil, ParserResult, Util}
  alias Types.UnionType

  @doc """
  Returns true if the json subschema represents a union type.

  ## Examples

  iex> type?(%{})
  false

  iex> type?(%{"type" => ["number", "integer", "string"]})
  true

  """
  @impl JsonSchema.Parser.ParserBehaviour
  @spec type?(Types.schemaNode()) :: boolean
  def type?(%{"type" => types}) when is_list(types), do: true
  def type?(_schema_node), do: false

  @doc """
  Parses a JSON schema union type into an `JsonSchema.Types.UnionType`.
  """
  @impl JsonSchema.Parser.ParserBehaviour
  @spec parse(map, URI.t(), URI.t(), URI.t(), String.t()) ::
          ParserResult.t()
  def parse(%{"type" => types} = schema_node, _parent_id, id, path, name) do
    description = Map.get(schema_node, "description")

    unknown_type =
      types
      |> Enum.find(fn type ->
        type not in [
          "null",
          "boolean",
          "number",
          "integer",
          "string",
          "array",
          "object"
        ]
      end)

    errors =
      if unknown_type do
        [ErrorUtil.unknown_union_type(path, unknown_type)]
      else
        []
      end

    union_type = %UnionType{
      name: name,
      description: description,
      path: path,
      types: types |> Enum.map(&value_type_from_string/1)
    }

    union_type
    |> Util.create_type_dict(path, id)
    |> ParserResult.new([], errors)
  end

  @spec value_type_from_string(String.t()) :: UnionType.value_type()
  defp value_type_from_string(type) do
    case type do
      "null" -> :null
      "boolean" -> :boolean
      "integer" -> :integer
      "number" -> :number
      "string" -> :string
    end
  end
end
