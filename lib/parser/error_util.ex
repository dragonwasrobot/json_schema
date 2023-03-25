defmodule JsonSchema.Parser.ErrorUtil do
  @moduledoc """
  Contains helper functions for reporting parser errors.
  """

  alias Jason.DecodeError
  alias JsonSchema.{Parser, Types}
  alias Parser.{ParserError, Util}

  @spec could_not_read_file(Path.t()) :: ParserError.t()
  def could_not_read_file(schema_path) do
    error_msg = """

    Failed to read file at #{to_string(schema_path)}. Are you sure the file path is correct?

    """

    ParserError.new(to_string(schema_path), :could_not_read_file, error_msg)
  end

  @spec invalid_json(Path.t(), DecodeError.t()) :: ParserError.t()
  def invalid_json(schema_path, decode_error) do
    error_msg = """

    Failed to parse file at #{to_string(schema_path)} as JSON.

        #{DecodeError.message(decode_error)}

    """

    ParserError.new(to_string(schema_path), :invalid_json, error_msg)
  end

  @spec unsupported_schema_version(String.t(), [String.t()]) :: ParserError.t()
  def unsupported_schema_version(supplied_value, supported_versions) do
    root_path = URI.parse("#")
    stringified_value = sanitize_value(supplied_value)

    # TODO: Add a config/option argument for `json_schema` that can be used to
    # determine whether to return a human readable error description or a
    # machine readable error.

    error_msg = """
    Unsupported JSON schema version found at '#'.

        "$schema": #{stringified_value}
                   #{error_markings(stringified_value)}

    Was expecting one of the following types:

        #{inspect(supported_versions)}

    Hint: See the specification section 7. "The '$schema' keyword"
    <https://datatracker.ietf.org/doc/html/draft-handrews-json-schema-01#section-7>
    """

    ParserError.new(root_path, :unsupported_schema_version, error_msg)
  end

  @spec missing_property(Types.typeIdentifier(), String.t()) :: ParserError.t()
  def missing_property(identifier, property) do
    full_identifier = print_identifier(identifier)

    error_msg = """
    Could not find property '#{property}' at '#{full_identifier}'
    """

    ParserError.new(identifier, :missing_property, error_msg)
  end

  @spec invalid_enum(Types.typeIdentifier(), String.t(), [String.t()], Types.json_value()) ::
          ParserError.t()
  def invalid_enum(identifier, property, expected_values, actual_value) do
    stringified_value = sanitize_value(actual_value)

    full_identifier = print_identifier(identifier)
    padding = whitespace(property)

    error_msg = """
    Expected value of property '#{property}' at '#{full_identifier}'
    to be in #{inspect(expected_values)} but found the value #{stringified_value}

        "#{property}": #{stringified_value}
         #{padding}   #{error_markings(stringified_value)}

    """

    ParserError.new(identifier, :unexpected_value, error_msg)
  end

  @spec invalid_type(Types.typeIdentifier(), String.t(), String.t(), Types.json_value()) ::
          ParserError.t()
  def invalid_type(identifier, property, expected_type, actual_value) do
    actual_type = Util.get_type(actual_value)
    stringified_value = sanitize_value(actual_value)

    full_identifier = print_identifier(identifier)
    padding = whitespace(property)

    error_msg = """
    Expected value of property '#{property}' at '#{full_identifier}'
    to be of type '#{expected_type}' but found a value of type '#{actual_type}'

        "#{property}": #{stringified_value}
         #{padding}   #{error_markings(stringified_value)}

    """

    ParserError.new(identifier, :unexpected_type, error_msg)
  end

  @spec schema_name_collision(Types.typeIdentifier()) :: ParserError.t()
  def schema_name_collision(identifier) do
    full_identifier = print_identifier(identifier)

    error_msg = """
    Found more than one schema with id: '#{full_identifier}'
    """

    ParserError.new(identifier, :name_collision, error_msg)
  end

  @spec name_collision(Types.typeIdentifier()) :: ParserError.t()
  def name_collision(identifier) do
    full_identifier = print_identifier(identifier)

    error_msg = """
    Found more than one property with identifier '#{full_identifier}'
    """

    ParserError.new(identifier, :name_collision, error_msg)
  end

  @spec name_not_a_regex(Types.typeIdentifier(), String.t()) :: ParserError.t()
  def name_not_a_regex(identifier, property) do
    full_identifier = print_identifier(identifier)

    error_msg = """
    Could not parse pattern '#{property}' at '#{full_identifier}' into a valid Regular Expression.

    Hint: See specification section 6.5.5 "patternProperties"
    <https://datatracker.ietf.org/doc/html/draft-handrews-json-schema-validation-01#section-6.5.5>
    """

    ParserError.new(identifier, :name_not_a_regex, error_msg)
  end

  @spec invalid_uri(Types.typeIdentifier(), String.t(), String.t()) ::
          ParserError.t()
  def invalid_uri(identifier, property, actual) do
    full_identifier = print_identifier(identifier)
    stringified_value = sanitize_value(actual)

    error_msg = """
    Could not parse property '#{property}' at '#{full_identifier}' into a valid URI.

        "id": #{stringified_value}
              #{error_markings(stringified_value)}

    Hint: See URI specification section 3. "Syntax Components"
    <https://datatracker.ietf.org/doc/html/rfc3986#section-3>
    """

    ParserError.new(identifier, :invalid_uri, error_msg)
  end

  @spec unresolved_reference(
          Types.typeIdentifier(),
          URI.t()
        ) :: ParserError.t()
  def unresolved_reference(identifier, parent) do
    printed_path = to_string(parent)
    stringified_value = sanitize_value(identifier)

    error_msg = """

    The following reference at `#{printed_path}` could not be resolved

        "$ref": #{stringified_value}
                #{error_markings(stringified_value)}

    Hint: See the specification section 8.2 "Base URI and Dereferencing"
    <https://datatracker.ietf.org/doc/html/draft-handrews-json-schema-01#section-8>
    """

    ParserError.new(parent, :unresolved_reference, error_msg)
  end

  @spec unknown_type(String.t()) :: ParserError.t()
  def unknown_type(type_name) do
    error_msg = "Could not find parser for type: '#{type_name}'"
    ParserError.new(type_name, :unknown_type, error_msg)
  end

  @spec unexpected_type(Types.typeIdentifier(), String.t()) :: ParserError.t()
  def unexpected_type(identifier, error_msg) do
    ParserError.new(identifier, :unexpected_type, error_msg)
  end

  @spec unknown_union_type(Types.typeIdentifier(), String.t()) ::
          ParserError.t()
  def unknown_union_type(identifier, type_name) do
    printed_path = to_string(identifier)

    error_msg = """

    Encountered unknown union type at `#{printed_path}`

        "type": [#{type_name}]
                #{error_markings(type_name)}

    Hint: See the specification section 6. "Validation Keywords"
    <https://datatracker.ietf.org/doc/html/draft-handrews-json-schema-validation-01#section-6.1.1>
    """

    ParserError.new(identifier, :unknown_union_type, error_msg)
  end

  @spec unknown_enum_type(String.t()) :: ParserError.t()
  def unknown_enum_type(type_name) do
    error_msg = "Unknown or unsupported enum type: '#{type_name}'"
    ParserError.new(type_name, :unknown_enum_type, error_msg)
  end

  @spec unknown_primitive_type(String.t()) :: ParserError.t()
  def unknown_primitive_type(type_name) do
    error_msg = "Unknown or unsupported primitive type: '#{type_name}'"
    ParserError.new(type_name, :unknown_primitive_type, error_msg)
  end

  @spec unknown_node_type(
          URI.t(),
          String.t() | :anonymous,
          Types.schemaNode()
        ) :: ParserError.t()
  def unknown_node_type(identifier, name, schema_node) do
    full_identifier =
      if name == :anonymous do
        identifier |> to_string()
      else
        identifier
        |> Util.add_fragment_child(name)
        |> to_string()
      end

    stringified_value = sanitize_value(schema_node)

    error_msg = """
    The value of "type" at '#{full_identifier}' did not match a known node type

        "type": #{stringified_value}
                #{error_markings(stringified_value)}

    Was expecting one of the following types

        ["null", "boolean", "object", "array", "number", "integer", "string"]

    Hint: See the specification section 6.25. "Validation keywords - type"
    <https://json-schema.org/draft/2020-12/json-schema-validation.html#rfc.section.6.1>
    """

    ParserError.new(full_identifier, :unknown_node_type, error_msg)
  end

  @spec print_identifier(Types.typeIdentifier()) :: String.t()
  defp print_identifier(identifier) do
    to_string(identifier)
  end

  @spec sanitize_value(value :: any) :: String.t()
  defp sanitize_value(%URI{} = value), do: URI.to_string(value)
  defp sanitize_value(value) when is_list(value), do: Jason.encode!(value)
  defp sanitize_value(value) when is_map(value), do: Jason.encode!(value)
  defp sanitize_value(value), do: inspect(value)

  @spec error_markings(String.t()) :: [String.t()]
  defp error_markings(value) do
    red(String.duplicate("^", String.length(value)))
  end

  @spec whitespace(String.t()) :: String.t()
  defp whitespace(value) do
    String.duplicate(" ", String.length(value))
  end

  @spec red(String.t()) :: [String.t()]
  defp red(str) do
    IO.ANSI.format([:red, str])
  end
end
