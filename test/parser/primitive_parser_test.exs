defmodule JsonSchemaTest.Parser.PrimitiveParser do
  use ExUnit.Case
  doctest JsonSchema.Parser.PrimitiveParser, import: true

  alias JsonSchema.{Parser, Types}
  alias Parser.PrimitiveParser
  alias Types.PrimitiveType

  test "parse primitive type" do
    parser_result =
      """
      {
        "type": "string"
      }
      """
      |> Jason.decode!()
      |> PrimitiveParser.parse(nil, nil, URI.parse("#/primitive"), "primitive")

    expected_primitive_type = %PrimitiveType{
      name: "primitive",
      path: URI.parse("#/primitive"),
      type: :string
    }

    assert parser_result.errors == []
    assert parser_result.warnings == []

    assert parser_result.type_dict == %{
             "#/primitive" => expected_primitive_type
           }
  end
end
