defmodule JsonSchema.Parser.Util do
  @moduledoc """
  A module containing utility functions for JSON schema parsers.
  """

  require Logger

  alias JsonSchema.{Parser, Types}

  alias Parser.{
    AllOfParser,
    AnyOfParser,
    ArrayParser,
    DefinitionsParser,
    EnumParser,
    ErrorUtil,
    ObjectParser,
    OneOfParser,
    ParserResult,
    PrimitiveParser,
    TupleParser,
    TypeReferenceParser,
    UnionParser
  }

  @type nodeParser ::
          (Types.schemaNode(), URI.t(), URI.t(), URI.t(), String.t() ->
             ParserResult.t())

  @doc ~S"""
  Returns the name of the type of the given value.

  ## Examples

  iex> get_type([1,2,3])
  "list"

  iex> get_type(%{"type" => "string"})
  "object"

  iex> get_type("name")
  "string"

  iex> get_type(42)
  "integer"

  """
  @spec get_type(any) :: String.t()
  def get_type(value) when is_list(value), do: "list"
  def get_type(value) when is_map(value), do: "object"
  def get_type(value) when is_binary(value), do: "string"
  def get_type(value) when is_boolean(value), do: "boolean"
  def get_type(value) when is_float(value), do: "float"
  def get_type(value) when is_integer(value), do: "integer"
  def get_type(value) when is_nil(value), do: "null"
  def get_type(_value), do: "unknown"

  @doc """
  Creates a new type dictionary based on the given type definition
  and an optional ID.
  """
  @spec create_type_dict(
          Types.typeDefinition(),
          URI.t(),
          URI.t() | nil
        ) :: Types.typeDictionary()
  def create_type_dict(type_def, path, id) do
    string_path = path |> to_string()

    type_dict =
      if id != nil do
        string_id =
          if string_path == "#" do
            "#{id}#"
          else
            "#{id}"
          end

        %{string_path => type_def, string_id => type_def}
      else
        %{string_path => type_def}
      end

    type_dict
  end

  @doc """
  Returns a list of type paths when given a type dictionary.
  """
  @spec create_types_list(Types.typeDictionary(), URI.t()) :: [
          URI.t()
        ]
  def create_types_list(type_dict, path) do
    type_dict
    |> Enum.reduce(MapSet.new(), fn {child_abs_path, child_type}, acc_set ->
      normalized_child_name = child_type.name

      if normalized_child_name == :anonymous do
        child_abs_path_parts =
          child_abs_path
          |> String.split("/")

        child_prefix_path =
          child_abs_path_parts
          |> Enum.drop(-1)
          |> Enum.join("/")
          |> URI.parse()

        shares_prefix = child_prefix_path == path

        last_path_part_is_number =
          child_abs_path_parts
          |> List.last()
          |> Integer.parse() != :error

        if shares_prefix and last_path_part_is_number do
          MapSet.put(acc_set, URI.parse(child_abs_path))
        else
          acc_set
        end
      else
        child_type_path = add_fragment_child(path, normalized_child_name)

        if child_type_path == URI.parse(child_abs_path) do
          MapSet.put(acc_set, child_type_path)
        else
          acc_set
        end
      end
    end)
    |> MapSet.to_list()
  end

  @doc """
  Parse a list of JSON schema objects that have a child relation to another
  schema object with the specified `parent_id`.
  """
  @spec parse_child_types([Types.schemaNode()], URI.t(), URI.t()) ::
          ParserResult.t()
  def parse_child_types(child_nodes, parent_id, path)
      when is_list(child_nodes) do
    child_nodes
    |> Enum.reduce({ParserResult.new(), 0}, fn child_node, {result, idx} ->
      child_result =
        parse_type(
          child_node,
          parent_id,
          add_fragment_child(path, to_string(idx)),
          :anonymous
        )

      {ParserResult.merge(result, child_result), idx + 1}
    end)
    |> elem(0)
  end

  @doc """
  Parses a node type.
  """
  @spec parse_type(
          Types.schemaNode(),
          URI.t() | nil,
          URI.t(),
          String.t() | :anonymous,
          boolean
        ) ::
          ParserResult.t()
  def parse_type(schema_node, parent_id, path, name, name_is_regex \\ false) do
    definitions_result =
      if DefinitionsParser.type?(schema_node) do
        id = determine_id(schema_node, parent_id)
        child_parent_id = determine_parent_id(id, parent_id)
        type_path = add_fragment_child(path, name)

        DefinitionsParser.parse(
          schema_node,
          child_parent_id,
          id,
          type_path,
          name
        )
      else
        ParserResult.new(%{}, [], [])
      end

    node_result =
      case determine_node_parser(schema_node) do
        nil ->
          ParserResult.new(%{}, [], [])

        node_parser ->
          id = determine_id(schema_node, parent_id)
          child_parent_id = determine_parent_id(id, parent_id)
          type_path = add_fragment_child(path, name)

          node_parser.(schema_node, child_parent_id, id, type_path, name)
      end

    regex_result =
      if name_is_regex == true do
        case Regex.compile(name) do
          {:ok, _regex} ->
            ParserResult.new()

          {:error, _error} ->
            id = to_string(path)
            parser_error = ErrorUtil.name_not_a_regex(id, name)
            ParserResult.new(%{}, [], [parser_error])
        end
      else
        ParserResult.new()
      end

    if Enum.empty?(definitions_result.type_dict) and
         Enum.empty?(node_result.type_dict) do
      unknown_type_error = ErrorUtil.unknown_node_type(path, name, schema_node)
      ParserResult.new(%{}, [], [unknown_type_error])
    else
      definitions_result
      |> ParserResult.merge(node_result)
      |> ParserResult.merge(regex_result)
    end
  end

  @spec determine_node_parser(Types.schemaNode()) :: nodeParser | nil
  defp determine_node_parser(schema_node) do
    predicate_node_type_pairs = [
      {&AllOfParser.type?/1, &AllOfParser.parse/5},
      {&AnyOfParser.type?/1, &AnyOfParser.parse/5},
      {&ArrayParser.type?/1, &ArrayParser.parse/5},
      {&EnumParser.type?/1, &EnumParser.parse/5},
      {&ObjectParser.type?/1, &ObjectParser.parse/5},
      {&OneOfParser.type?/1, &OneOfParser.parse/5},
      {&PrimitiveParser.type?/1, &PrimitiveParser.parse/5},
      {&TupleParser.type?/1, &TupleParser.parse/5},
      {&TypeReferenceParser.type?/1, &TypeReferenceParser.parse/5},
      {&UnionParser.type?/1, &UnionParser.parse/5}
    ]

    {_pred?, node_parser} =
      predicate_node_type_pairs
      |> Enum.find({nil, nil}, fn {pred?, _node_parser} ->
        pred?.(schema_node)
      end)

    node_parser
  end

  @spec determine_id(map, URI.t() | nil) :: URI.t() | nil
  defp determine_id(%{"$id" => id}, parent_id) when is_binary(id) do
    do_determine_id(id, parent_id)
  end

  defp determine_id(_schema_node, _parent_id), do: nil

  @spec do_determine_id(String.t(), URI.t()) :: URI.t()
  defp do_determine_id(id, parent_id) do
    id_uri = URI.parse(id)

    if id_uri.scheme == "urn" do
      id_uri
    else
      URI.merge(parent_id, id_uri)
    end
  end

  @spec determine_parent_id(URI.t() | nil, URI.t()) :: URI.t()
  defp determine_parent_id(id, parent_id) do
    if id != nil and id.scheme != "urn" do
      id
    else
      parent_id
    end
  end

  @doc """
  Adds a child to the fragment of a `URI`.

  ## Examples

      iex> add_fragment_child(URI.parse("#/definitions/foo"), "bar")
      URI.parse("#/definitions/foo/bar")

  """
  @spec add_fragment_child(URI.t(), String.t() | :anonymous) :: URI.t()
  def add_fragment_child(uri, :anonymous) do
    uri
  end

  def add_fragment_child(uri, child) do
    old_fragment = uri.fragment

    new_fragment =
      case old_fragment do
        nil ->
          "/#{child}"

        "" ->
          "/#{child}"

        old_path ->
          Path.join(old_path, child)
      end

    %{uri | fragment: new_fragment}
  end
end
