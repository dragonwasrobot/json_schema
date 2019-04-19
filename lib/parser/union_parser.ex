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
  alias Parser.{ParserResult, Util}
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

    union_type = %UnionType{
      name: name,
      description: description,
      path: path,
      types: types
    }

    union_type
    |> Util.create_type_dict(path, id)
    |> ParserResult.new()
  end
end
