defmodule JsonSchema.Parser.EnumParser do
  @behaviour JsonSchema.Parser.ParserBehaviour
  @moduledoc """
  Parse a JSON schema enum type:

      {
        "type": "string",
        "enum": ["none", "green", "orange", "blue", "yellow", "red"]
      }

  Into an `JsonSchema.Types.EnumType`.
  """

  require Logger
  alias JsonSchema.{Parser, Types}
  alias Parser.{ParserResult, Util}
  alias Types.EnumType

  @doc """
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
  def parse(%{"enum" => enum, "type" => type}, _parent_id, id, path, name) do
    # TODO: Check that the enum values all have the same type

    enum_type = EnumType.new(name, path, type, enum)

    enum_type
    |> Util.create_type_dict(path, id)
    |> ParserResult.new()
  end
end
