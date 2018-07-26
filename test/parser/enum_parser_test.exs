defmodule JsonSchemaTest.Parser.EnumParser do
  use ExUnit.Case
  doctest JsonSchema.Parser.EnumParser, import: true

  alias JsonSchema.Parser.EnumParser
  alias JsonSchema.Types.EnumType

  test "parse enum type with integer values" do
    parser_result =
      ~S"""
      {
        "type": "integer",
        "enum": [1, 2, 3]
      }
      """
      |> Poison.decode!()
      |> EnumParser.parse(nil, nil, ["#", "favoriteNumber"], "favoriteNumber")

    expected_enum_type = %EnumType{
      name: "favoriteNumber",
      path: ["#", "favoriteNumber"],
      type: "integer",
      values: [1, 2, 3]
    }

    assert parser_result.errors == []
    assert parser_result.warnings == []

    assert parser_result.type_dict == %{
             "#/favoriteNumber" => expected_enum_type
           }
  end

  test "parse enum type with string values" do
    parser_result =
      ~S"""
      {
        "type": "string",
        "enum": ["none", "green", "orange", "blue", "yellow", "red"]
      }
      """
      |> Poison.decode!()
      |> EnumParser.parse(nil, nil, ["#", "color"], "color")

    expected_enum_type = %EnumType{
      name: "color",
      path: ["#", "color"],
      type: "string",
      values: ["none", "green", "orange", "blue", "yellow", "red"]
    }

    assert parser_result.errors == []
    assert parser_result.warnings == []

    assert parser_result.type_dict == %{
             "#/color" => expected_enum_type
           }
  end
end
