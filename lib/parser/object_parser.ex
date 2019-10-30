defmodule JsonSchema.Parser.ObjectParser do
  @behaviour JsonSchema.Parser.ParserBehaviour
  @moduledoc """
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
  alias JsonSchema.{Parser, Types}
  alias Parser.{ParserResult, Util}
  alias Types.ObjectType

  @doc """
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

  @doc """
  Parses a JSON schema object type into an `JsonSchema.Types.ObjectType`.
  """
  @impl JsonSchema.Parser.ParserBehaviour
  @spec parse(Types.schemaNode(), URI.t() | nil, URI.t(), URI.t(), String.t()) ::
          ParserResult.t()
  def parse(schema_node, parent_id, id, path, name) do
    required = Map.get(schema_node, "required", [])
    description = Map.get(schema_node, "description")
    properties_path = Util.add_fragment_child(path, "properties")

    properties_result =
      schema_node
      |> Map.get("properties")
      |> parse_child_types(parent_id, properties_path)

    properties_type_dict =
      create_property_dict(properties_result.type_dict, properties_path, id)

    pattern_properties_path = Util.add_fragment_child(path, "patternProperties")

    pattern_properties_result =
      if schema_node["patternProperties"] != nil do
        schema_node
        |> Map.get("patternProperties")
        |> parse_child_types(parent_id, pattern_properties_path, true)
      else
        ParserResult.new()
      end

    pattern_properties_type_dict =
      create_property_dict(
        pattern_properties_result.type_dict,
        pattern_properties_path,
        id
      )

    {additional_properties_path, additional_properties_result} =
      if schema_node["additionalProperties"] != nil do
        parser_result =
          schema_node
          |> Map.get("additionalProperties")
          |> Util.parse_type(parent_id, path, "additionalProperties")

        if parser_result != nil do
          {Util.add_fragment_child(path, "additionalProperties"), parser_result}
        else
          {nil, ParserResult.new()}
        end
      else
        {nil, ParserResult.new()}
      end

    object_type = %ObjectType{
      name: name,
      description: description,
      path: path,
      properties: properties_type_dict,
      pattern_properties: pattern_properties_type_dict,
      additional_properties: additional_properties_path,
      required: required
    }

    object_type
    |> Util.create_type_dict(path, id)
    |> ParserResult.new()
    |> ParserResult.merge(properties_result)
    |> ParserResult.merge(pattern_properties_result)
    |> ParserResult.merge(additional_properties_result)
  end

  @spec parse_child_types(map, URI.t(), URI.t(), boolean) :: ParserResult.t()
  defp parse_child_types(
         node_properties,
         parent_id,
         child_path,
         name_is_regex \\ false
       ) do
    init_result = ParserResult.new()

    node_properties
    |> Enum.reduce(init_result, fn {child_name, child_node}, acc_result ->
      child_types =
        Util.parse_type(
          child_node,
          parent_id,
          child_path,
          child_name,
          name_is_regex
        )

      ParserResult.merge(acc_result, child_types)
    end)
  end

  @doc """
  Creates a property dictionary based on a type dictionary and a type path.

  ## Examples

      iex> type_dict = %{}
      ...> path = URI.parse("#")
      ...> id = "http://www.example.com/root.json"
      ...> JsonSchema.Parser.ObjectParser.create_property_dict(type_dict, path, id)
      %{}

  """
  @spec create_property_dict(Types.typeDictionary(), URI.t(), URI.t() | nil) ::
          Types.propertyDictionary()
  def create_property_dict(type_dict, path, id) do
    type_dict
    |> Enum.reduce(%{}, fn {child_path, child_type}, acc_property_dict ->
      if is_immediate_child(child_path, child_type.name, path, id) do
        child_type_path = Util.add_fragment_child(path, child_type.name)
        child_property_dict = %{child_type.name => child_type_path}
        Map.merge(acc_property_dict, child_property_dict)
      else
        acc_property_dict
      end
    end)
  end

  @spec is_immediate_child(URI.t(), String.t(), URI.t(), URI.t() | nil) ::
          boolean
  defp is_immediate_child(child_path, child_name, properties_path, id) do
    child_path_alt = Util.add_fragment_child(properties_path, child_name)

    if id == nil do
      to_string(child_path) == to_string(child_path_alt)
    else
      absolute_child_path_alt = %{id | fragment: child_path_alt.fragment}

      to_string(child_path) == to_string(child_path_alt) ||
        to_string(child_path) == to_string(absolute_child_path_alt)
    end
  end
end
