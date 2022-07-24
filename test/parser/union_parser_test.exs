defmodule JsonSchemaTest.Parser.UnionParser do
  use ExUnit.Case
  doctest JsonSchema.Parser.UnionParser, import: true

  alias JsonSchema.{Parser, Types}
  alias Parser.UnionParser
  alias Types.UnionType

  test "parse primitive union type" do
    parser_result =
      """
      {
        "type": ["number", "integer", "null"],
        "default": 42
      }
      """
      |> Jason.decode!()
      |> UnionParser.parse(nil, nil, URI.parse("#/union"), "union")

    expected_union_type = %UnionType{
      name: "union",
      path: URI.parse("#/union"),
      default: 42,
      types: [:number, :integer, :null]
    }

    assert parser_result.errors == []
    assert parser_result.warnings == []

    assert parser_result.type_dict == %{
             "#/union" => expected_union_type
           }
  end
end
