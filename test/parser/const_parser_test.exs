defmodule JsonSchemaTest.Parser.ConstParser do
  use ExUnit.Case
  doctest JsonSchema.Parser.ConstParser, import: true

  alias JsonSchema.Parser.ConstParser
  alias JsonSchema.Types.ConstType

  test "parse const type with number value" do
    parser_result =
      """
      {
        "type": "integer",
        "const": 42
      }
      """
      |> Jason.decode!()
      |> ConstParser.parse(
        nil,
        nil,
        URI.parse("#/favoriteNumber"),
        "favoriteNumber"
      )

    expected_const_type = %ConstType{
      name: "favoriteNumber",
      path: URI.parse("#/favoriteNumber"),
      type: "integer",
      const: 42
    }

    assert parser_result.errors == []
    assert parser_result.warnings == []

    assert parser_result.type_dict == %{
             "#/favoriteNumber" => expected_const_type
           }
  end

  test "parse const type with map value" do
    parser_result =
      """
      {
        "type": "object",
        "const": {"foo": 43, "bar": "helicopter"}
      }
      """
      |> Jason.decode!()
      |> ConstParser.parse(nil, nil, URI.parse("#/myStruct"), "myStruct")

    expected_const_type = %ConstType{
      name: "myStruct",
      path: URI.parse("#/myStruct"),
      type: "object",
      const: %{"foo" => 43, "bar" => "helicopter"}
    }

    assert parser_result.errors == []
    assert parser_result.warnings == []
    assert parser_result.type_dict == %{"#/myStruct" => expected_const_type}
  end
end
