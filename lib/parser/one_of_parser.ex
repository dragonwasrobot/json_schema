defmodule JsonSchema.Parser.OneOfParser do
  @behaviour JsonSchema.Parser.ParserBehaviour
  @moduledoc """
  Parses a JSON schema oneOf type:

      {
        "oneOf": [
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

  Into an `JsonSchema.Types.OneOfType`.
  """

  require Logger
  alias JsonSchema.{Parser, Types}
  alias Parser.{ParserResult, Util}
  alias Types.OneOfType

  @doc """
  Returns true if the json subschema represents an oneOf type.

  ## Examples

  iex> type?(%{})
  false

  iex> type?(%{"oneOf" => []})
  false

  iex> type?(%{"oneOf" => [%{"$ref" => "#foo"}]})
  true

  """
  @impl JsonSchema.Parser.ParserBehaviour
  @spec type?(Types.schemaNode()) :: boolean
  def type?(%{"oneOf" => one_of}) when is_list(one_of) and length(one_of) > 0, do: true
  def type?(_schema_node), do: false

  @doc """
  Parses a JSON schema oneOf type into an `JsonSchema.Types.OneOfType`.
  """
  @impl JsonSchema.Parser.ParserBehaviour
  @spec parse(Types.schemaNode(), URI.t(), URI.t(), URI.t(), String.t()) ::
          ParserResult.t()
  def parse(%{"oneOf" => one_of} = schema_node, parent_id, id, path, name)
      when is_list(one_of) do
    description = Map.get(schema_node, "description")
    default = Map.get(schema_node, "default")
    child_path = Util.add_fragment_child(path, "oneOf")

    child_types_result =
      one_of
      |> Util.parse_child_types(parent_id, child_path)

    one_of_types =
      child_types_result.type_dict
      |> Util.create_types_list(child_path)

    one_of_type = %OneOfType{
      name: name,
      description: description,
      default: default,
      path: path,
      types: one_of_types
    }

    one_of_type
    |> Util.create_type_dict(path, id)
    |> ParserResult.new()
    |> ParserResult.merge(child_types_result)
  end
end
