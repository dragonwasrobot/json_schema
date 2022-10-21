defmodule JsonSchemaTest.Parser.ArrayParser do
  use ExUnit.Case
  doctest JsonSchema.Parser.ArrayParser, import: true

  alias JsonSchema.{Parser, Types}
  alias Parser.ArrayParser
  alias Types.{ArrayType, TypeReference, PrimitiveType}

  test "parse array with primitive type" do
    parser_result =
      """
      {
        "type": "array",
        "items": {
          "type": "string"
        }
      }
      """
      |> Jason.decode!()
      |> ArrayParser.parse(nil, nil, URI.parse("#/notes"), "notes")

    expected_array_type = %ArrayType{
      name: "notes",
      description: nil,
      path: URI.parse("#/notes"),
      items: URI.parse("#/notes/items")
    }

    expected_primitive_type = %PrimitiveType{
      name: "items",
      description: nil,
      default: nil,
      path: URI.parse("#/notes/items"),
      type: :string
    }

    assert parser_result.errors == []
    assert parser_result.warnings == []

    assert parser_result.type_dict == %{
             "#/notes" => expected_array_type,
             "#/notes/items" => expected_primitive_type
           }
  end

  test "parse array with ref type" do
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
