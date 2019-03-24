defmodule JsonSchemaTest.Parser.Util do
  @moduledoc """
  Tests for the parser utilities functions.
  """
  use ExUnit.Case
  doctest JsonSchema.Parser.Util, import: true

  alias JsonSchema.Parser.Util

  test "Returns ParserError when parsing empty node" do
    schema_node = %{}
    parent_id = URI.parse("#")
    path = URI.parse("#/bad")
    name = ""

    %JsonSchema.Parser.ParserResult{
      type_dict: %{},
      warnings: [],
      errors: [
        %JsonSchema.Parser.ParserError{
          identifier: "#/bad",
          error_type: :unknown_node_type,
          message: _message
        }
      ]
    } = Util.parse_type(schema_node, parent_id, path, name)
  end
end
