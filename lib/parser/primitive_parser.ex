defmodule JsonSchema.Parser.PrimitiveParser do
  @behaviour JsonSchema.Parser.ParserBehaviour
  @moduledoc ~S"""
  Parses a JSON schema primitive type:

      {
        "description": "A name",
        "default": "Steve",
        "type": "string"
      }

  Into an `JsonSchema.Types.PrimitiveType`.
  """

  require Logger

  alias JsonSchema.{Parser, Types}
  alias Parser.{ErrorUtil, ParserResult, Util}
  alias Types.PrimitiveType

  @primitive_types ["null", "boolean", "integer", "number", "string"]

  @doc ~S"""
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
  @spec type?(Types.schemaNode()) :: boolean
  def type?(%{"type" => type}) when type in @primitive_types, do: true
  def type?(_schema_node), do: false

  @doc """
  Parses a JSON schema primitive type into an `JsonSchema.Types.PrimitiveType`.
  """
  @impl JsonSchema.Parser.ParserBehaviour
  @spec parse(Types.schemaNode(), URI.t(), URI.t(), URI.t(), String.t()) ::
          ParserResult.t()
  def parse(%{"type" => type} = schema_node, _parent_id, id, path, name) do
    description = Map.get(schema_node, "description")
    default = Map.get(schema_node, "default")
    value_type = value_type_from_string(type)

    errors =
      if default != nil && not default_value_has_proper_type?(default, value_type) do
        [ErrorUtil.invalid_type(path, "default", to_string(value_type), default)]
      else
        []
      end

    primitive_type = %PrimitiveType{
      name: name,
      description: description,
      default: default,
      path: path,
      type: value_type
    }

    primitive_type
    |> Util.create_type_dict(path, id)
    |> ParserResult.new([], errors)
  end

  @spec value_type_from_string(String.t()) :: PrimitiveType.value_type()
  defp value_type_from_string(type) do
    case type do
      "null" -> :null
      "boolean" -> :boolean
      "integer" -> :integer
      "number" -> :number
      "string" -> :string
    end
  end

  @spec default_value_has_proper_type?(PrimitiveType.default_value(), PrimitiveType.value_type()) ::
          boolean
  defp default_value_has_proper_type?(default, value_type) do
    cond do
      value_type == :boolean and not is_boolean(default) -> false
      value_type == :integer and not is_integer(default) -> false
      value_type == :number and not is_number(default) -> false
      value_type == :string and not is_binary(default) -> false
      true -> true
    end
  end
end
