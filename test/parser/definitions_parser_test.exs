defmodule JsonSchemaTest.Parser.DefinitionsParser do
  use ExUnit.Case
  doctest JsonSchema.Parser.DefinitionsParser, import: true

  alias JsonSchema.{Parser, Types}
  alias Parser.RootParser
  alias Types.{ArrayType, PrimitiveType, SchemaDefinition, TypeReference}

  test "parse definitions" do
    schema_result =
      ~S"""
      {
        "$schema": "http://json-schema.org/draft-04/schema#",
        "id": "http://example.com/root.json",
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
      |> Poison.decode!()
      |> RootParser.parse_schema("examples/example.json")

    expected_root_type_reference = %ArrayType{
      name: "Root",
      path: ["#"],
      items: ["#", "items"]
    }

    expected_type_reference = %TypeReference{
      name: "items",
      path: ["#", "definitions", "positiveInteger"]
    }

    expected_primitive_type = %PrimitiveType{
      name: "positiveInteger",
      path: ["#", "definitions", "positiveInteger"],
      type: "integer"
    }

    assert schema_result.errors == []
    assert schema_result.warnings == []

    assert schema_result.schema_dict == %{
             "http://example.com/root.json" => %SchemaDefinition{
               file_path: "examples/example.json",
               title: "Root",
               id: URI.parse("http://example.com/root.json"),
               types: %{
                 "#" => expected_root_type_reference,
                 "http://example.com/root.json#" =>
                   expected_root_type_reference,
                 "#/items" => expected_type_reference,
                 "#/definitions/positiveInteger" => expected_primitive_type
               }
             }
           }
  end
end
