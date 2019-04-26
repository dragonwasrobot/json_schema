defmodule JsonSchema.Parser.ConstParser do
  @behaviour JsonSchema.Parser.ParserBehaviour
  @moduledoc """
  Parse a JSON schema const type:

      {
        "type": "string",
        "const": "This is a constant"
      }

  Into an `JsonSchema.Types.ConstType`.
  """

  require Logger
  alias JsonSchema.{Parser, Types}
  alias Parser.{ParserResult, Util}
  alias Types.ConstType

  @doc """
  Returns true if the json subschema represents an const type.

  ## Examples

  iex> type?(%{})
  false

  iex> type?(%{"const" => nil})
  true

  iex> type?(%{"const" => false})
  true

  iex> type?(%{"const" => "23.4"})
  true

  iex> type?(%{"const" => "This is a constant"})
  true

  iex> type?(%{"const" => %{"foo" => 42}})
  true
  """
  @impl JsonSchema.Parser.ParserBehaviour
  @spec type?(Types.schemaNode()) :: boolean
  def type?(%{"const" => const})
      when is_nil(const) or is_boolean(const) or is_number(const) or
             is_binary(const) or is_list(const) or is_map(const),
      do: true

  def type?(_schema_node), do: false

  @doc """
  Parses a JSON schema const type into an `JsonSchema.Types.ConstType`.
  """
  @impl JsonSchema.Parser.ParserBehaviour
  @spec parse(
          Types.schemaNode(),
          URI.t(),
          URI.t() | nil,
          URI.t(),
          String.t()
        ) :: ParserResult.t()
  def parse(%{"const" => const} = schema_node, _parent_id, id, path, name) do
    description = Map.get(schema_node, "description")
    type = Map.get(schema_node, "type")

    const_type = %ConstType{
      name: name,
      description: description,
      path: path,
      type: type,
      const: const
    }

    const_type
    |> Util.create_type_dict(path, id)
    |> ParserResult.new()
  end
end
