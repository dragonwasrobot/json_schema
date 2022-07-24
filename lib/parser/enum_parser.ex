defmodule JsonSchema.Parser.EnumParser do
  @behaviour JsonSchema.Parser.ParserBehaviour
  @moduledoc ~S"""
  Parse a JSON schema enum type:

      {
        "type": "string",
        "enum": ["none", "green", "orange", "blue", "yellow", "red"]
      }

  Into an `JsonSchema.Types.EnumType`.
  """

  require Logger
  alias JsonSchema.{Parser, Types}
  alias Parser.{ErrorUtil, ParserResult, Util}
  alias Types.EnumType

  @doc ~S"""
  Returns true if the json subschema represents an enum type.

  ## Examples

  iex> type?(%{})
  false

  iex> type?(%{"enum" => ["red", "yellow", "green"], "type" => "string"})
  true

  """
  @impl JsonSchema.Parser.ParserBehaviour
  @spec type?(Types.schemaNode()) :: boolean
  def type?(%{"enum" => enum, "type" => type})
      when is_list(enum) and is_binary(type),
      do: true

  def type?(_schema_node), do: false

  @doc """
  Parses a JSON schema enum type into an `JsonSchema.Types.EnumType`.
  """
  @impl JsonSchema.Parser.ParserBehaviour
  @spec parse(
          Types.schemaNode(),
          URI.t(),
          URI.t() | nil,
          URI.t(),
          String.t()
        ) :: ParserResult.t()
  def parse(%{"enum" => values} = schema_node, _parent_id, id, path, name) do
    description = Map.get(schema_node, "description")
    default = Map.get(schema_node, "default")
    type = schema_node |> Map.get("type") |> parse_enum_type()

    errors =
      if default != nil && not Enum.member?(values, default) do
        [ErrorUtil.invalid_enum(path, "default", values, default)]
      else
        []
      end

    enum_type = %EnumType{
      name: name,
      description: description,
      default: default,
      path: path,
      type: type,
      values: values
    }

    enum_type
    |> Util.create_type_dict(path, id)
    |> ParserResult.new([], errors)
  end

  @spec parse_enum_type(String.t()) :: EnumType.value_type()
  defp parse_enum_type(raw_type) do
    case raw_type do
      "string" -> :string
      "integer" -> :integer
      "number" -> :number
    end
  end
end
