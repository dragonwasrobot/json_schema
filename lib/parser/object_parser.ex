defmodule JsonSchema.Parser.ObjectParser do
  @behaviour JsonSchema.Parser.ParserBehaviour
  @moduledoc ~S"""
  Parses a JSON schema object type:

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
      }

  Into an `JsonSchema.Types.ObjectType`
  """

  require Logger
  alias JsonSchema.{Parser, TypePath, Types}
  alias Parser.{ParserResult, Util}
  alias Types.ObjectType

  @doc ~S"""
  Returns true if the json subschema represents an allOf type.

  ## Examples

  iex> type?(%{})
  false

  iex> an_object = %{"properties" => %{"name" => %{"type" => "string"}}}
  iex> type?(an_object)
  true

  """
  @impl JsonSchema.Parser.ParserBehaviour
  @spec type?(map) :: boolean
  def type?(schema_node) do
    properties = schema_node["properties"]
    is_map(properties)
  end

  @doc ~S"""
  Parses a JSON schema object type into an `JsonSchema.Types.ObjectType`.
  """
  @impl JsonSchema.Parser.ParserBehaviour
  @spec parse(Types.schemaNode(), URI.t(), URI.t(), TypePath.t(), String.t()) :: ParserResult.t()
  def parse(schema_node, parent_id, id, path, name) do
    required = Map.get(schema_node, "required", [])

    properties_path = TypePath.add_child(path, "properties")

    properties_result =
      schema_node
      |> Map.get("properties")
      |> parse_child_types(parent_id, properties_path)

    properties_type_dict = create_property_dict(properties_result.type_dict, properties_path)

    pattern_properties_path = TypePath.add_child(path, "patternProperties")

    pattern_properties_result =
      if schema_node["patternProperties"] != nil do
        schema_node
        |> Map.get("patternProperties")
        |> parse_child_types(parent_id, pattern_properties_path, true)
      else
        ParserResult.new()
      end

    pattern_properties_type_dict =
      create_property_dict(pattern_properties_result.type_dict, pattern_properties_path)

    object_type =
      ObjectType.new(name, path, properties_type_dict, pattern_properties_type_dict, required)

    object_type
    |> Util.create_type_dict(path, id)
    |> ParserResult.new()
    |> ParserResult.merge(properties_result)
    |> ParserResult.merge(pattern_properties_result)
  end

  @spec parse_child_types(map, URI.t(), TypePath.t(), boolean) :: ParserResult.t()
  defp parse_child_types(node_properties, parent_id, child_path, name_is_regex \\ false) do
    init_result = ParserResult.new()

    node_properties
    |> Enum.reduce(init_result, fn {child_name, child_node}, acc_result ->
      child_types = Util.parse_type(child_node, parent_id, child_path, child_name, name_is_regex)

      ParserResult.merge(acc_result, child_types)
    end)
  end

  @doc ~S"""
  Creates a property dictionary based on a type dictionary and a type path.

  ## Examples

      iex> type_dict = %{}
      ...> path = JsonSchema.TypePath.from_string("#")
      ...> JsonSchema.Parser.ObjectParser.create_property_dict(type_dict, path)
      %{}

  """
  @spec create_property_dict(Types.typeDictionary(), TypePath.t()) :: Types.propertyDictionary()
  def create_property_dict(type_dict, path) do
    type_dict
    |> Enum.reduce(%{}, fn {child_path, child_type}, acc_property_dict ->
      child_type_path = TypePath.add_child(path, child_type.name)

      if child_type_path == TypePath.from_string(child_path) do
        child_property_dict = %{child_type.name => child_type_path}
        Map.merge(acc_property_dict, child_property_dict)
      else
        acc_property_dict
      end
    end)
  end
end
