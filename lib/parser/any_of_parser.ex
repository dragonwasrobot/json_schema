defmodule JsonSchema.Parser.AnyOfParser do
  @behaviour JsonSchema.Parser.ParserBehaviour
  @moduledoc """
  Parses a JSON schema `anyOf` type:

      {
        "anyOf": [
          {
            "type": "object",
            "properties": {
              "color": {
                "$ref": "#/color"
              },
              "title": {
                "type": "string"
              },
              "radius": {
                "type": "number"
              }
            },
            "required": [ "color", "radius" ]
          },
          {
            "type": "string"
          }
        ]
      }

  Into an `JsonSchema.Types.AnyOfType`.
  """

  require Logger
  alias JsonSchema.{Parser, Types}
  alias Parser.{ParserResult, Util}
  alias Types.AnyOfType

  @doc """
  Returns true if the json subschema represents an anyOf type.

  ## Examples

  iex> type?(%{})
  false

  iex> type?(%{"anyOf" => []})
  false

  iex> type?(%{"anyOf" => [%{"$ref" => "#foo"}]})
  true

  """
  @impl JsonSchema.Parser.ParserBehaviour
  @spec type?(Types.schemaNode()) :: boolean
  def type?(schema_node) do
    any_of = schema_node["anyOf"]
    is_list(any_of) && length(any_of) > 0
  end

  @doc """
  Parses a JSON schema anyOf type into an `JsonSchema.Types.AnyOfType`.
  """
  @impl JsonSchema.Parser.ParserBehaviour
  @spec parse(
          Types.schemaNode(),
          URI.t(),
          URI.t() | nil,
          URI.t(),
          String.t()
        ) :: ParserResult.t()
  def parse(%{"anyOf" => any_of} = schema_node, parent_id, id, path, name)
      when is_list(any_of) do
    description = Map.get(schema_node, "description")
    child_path = Util.add_fragment_child(path, "anyOf")

    child_types_result =
      any_of
      |> Util.parse_child_types(parent_id, child_path)

    any_of_types =
      child_types_result.type_dict
      |> Util.create_types_list(child_path)

    any_of_type = %AnyOfType{
      name: name,
      description: description,
      path: path,
      types: any_of_types
    }

    any_of_type
    |> Util.create_type_dict(path, id)
    |> ParserResult.new()
    |> ParserResult.merge(child_types_result)
  end
end
