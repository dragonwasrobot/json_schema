defmodule JsonSchemaTest.Parser.DefinitionsParser do
  use ExUnit.Case
  doctest JsonSchema.Parser.DefinitionsParser, import: true

  alias JsonSchema.{Parser, Types}
  alias Parser.RootParser
  alias Types.{ArrayType, PrimitiveType, SchemaDefinition, TypeReference}

  test "parse definitions" do
    schema_result =
      """
      {
        "$schema": "http://json-schema.org/draft-07/schema#",
        "$id": "http://example.com/root.json",
        "type": "array",
        "items": { "$ref": "#/definitions/positiveInteger" },
        "definitions": {
          "positiveInteger": {
            "type": "integer",
            "minimum": 0,
            "exclusiveMinimum": true
          }
        }
      }
      """
      |> Jason.decode!()
      |> RootParser.parse_schema("examples/example.json")

    expected_root_type_reference = %ArrayType{
      name: "Root",
      path: URI.parse("#"),
      items: URI.parse("#/items")
    }

    expected_type_reference = %TypeReference{
      name: :anonymous,
      path: URI.parse("#/definitions/positiveInteger")
    }

    expected_primitive_type = %PrimitiveType{
      name: "positiveInteger",
      path: URI.parse("#/definitions/positiveInteger"),
      type: :integer
    }

    expected_schema_definition = %SchemaDefinition{
      file_path: "examples/example.json",
      title: "Root",
      id: URI.parse("http://example.com/root.json"),
      types: %{
        "#" => expected_root_type_reference,
        "http://example.com/root.json#" => expected_root_type_reference,
        "#/items" => expected_type_reference,
        "#/definitions/positiveInteger" => expected_primitive_type
      }
    }

    assert schema_result.errors == []
    assert schema_result.warnings == []

    assert schema_result.schema_dict == %{
             "http://example.com/root.json" => expected_schema_definition
           }
  end
end
