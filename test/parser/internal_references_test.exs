defmodule JsonSchemaTest.Parser.InternalReferences do
  use ExUnit.Case

  alias JsonSchema.{Parser, Types}
  alias Parser.RootParser
  alias Types.{PrimitiveType, SchemaDefinition, TypeReference}

  test "parse internal references" do
    schema_result =
      """
      {
        "$schema": "http://json-schema.org/draft-07/schema#",
        "description": "Demonstrates the different types of internal references",
        "title": "InternalReference",
        "$id": "http://example.com/root.json",
        "$ref": "#/definitions/C",
        "definitions": {
          "A": {
            "$id": "#foo",
            "description": "Some string named 'foo'",
            "type": "string"
          },
          "B": {
            "$id": "other.json",
            "definitions": {
              "X": {
                "$id": "#bar",
                "type": "boolean"
              },
              "Y": {
                "$id": "t/inner.json",
                "type": "number"
              }
            }
          },
          "C": {
            "$id": "urn:uuid:ee564b8a-7a87-4125-8c96-e9f123d6766f",
            "type": "integer"
          }
        }
      }
      """
      |> Jason.decode!()
      |> RootParser.parse_schema("examples/example.json")

    expected_root_type_reference = %TypeReference{
      name: "InternalReference",
      path: URI.parse("#/definitions/C")
    }

    expected_type_a = %PrimitiveType{
      name: "A",
      description: "Some string named 'foo'",
      path: URI.parse("#/definitions/A"),
      type: :string
    }

    expected_type_x = %PrimitiveType{
      name: "X",
      path: URI.parse("#/definitions/B/definitions/X"),
      type: :boolean
    }

    expected_type_y = %PrimitiveType{
      name: "Y",
      path: URI.parse("#/definitions/B/definitions/Y"),
      type: :number
    }

    expected_type_c = %PrimitiveType{
      name: "C",
      path: URI.parse("#/definitions/C"),
      type: :integer
    }

    expected_schema_definition = %SchemaDefinition{
      file_path: "examples/example.json",
      description: "Demonstrates the different types of internal references",
      title: "InternalReference",
      id: URI.parse("http://example.com/root.json"),
      types: %{
        "#" => expected_root_type_reference,
        "http://example.com/root.json#" => expected_root_type_reference,
        "#/definitions/A" => expected_type_a,
        "http://example.com/root.json#foo" => expected_type_a,
        "#/definitions/B/definitions/X" => expected_type_x,
        "http://example.com/other.json#bar" => expected_type_x,
        "#/definitions/B/definitions/Y" => expected_type_y,
        "http://example.com/t/inner.json" => expected_type_y,
        "#/definitions/C" => expected_type_c,
        "urn:uuid:ee564b8a-7a87-4125-8c96-e9f123d6766f" => expected_type_c
      }
    }

    assert schema_result.errors == []
    assert schema_result.warnings == []

    assert schema_result.schema_dict == %{
             "http://example.com/root.json" => expected_schema_definition
           }
  end
end
