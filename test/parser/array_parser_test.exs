defmodule JsonSchemaTest.Parser.ArrayParser do
  use ExUnit.Case
  doctest JsonSchema.Parser.ArrayParser, import: true

  alias JsonSchema.{Parser, Types}
  alias Parser.ArrayParser
  alias Types.{ArrayType, TypeReference}

  test "parse array type" do
    parser_result =
      """
      {
        "type": "array",
        "items": {
          "$ref": "#/definitions/rectangle"
        }
      }
      """
      |> Jason.decode!()
      |> ArrayParser.parse(nil, nil, URI.parse("#/rectangles"), "rectangles")

    expected_array_type = %ArrayType{
      name: "rectangles",
      description: nil,
      path: URI.parse("#/rectangles"),
      items: URI.parse("#/rectangles/items")
    }

    expected_type_reference = %TypeReference{
      name: "items",
      path: URI.parse("#/definitions/rectangle")
    }

    assert parser_result.errors == []
    assert parser_result.warnings == []

    assert parser_result.type_dict == %{
             "#/rectangles" => expected_array_type,
             "#/rectangles/items" => expected_type_reference
           }
  end
end
