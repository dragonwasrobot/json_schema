defmodule JsonSchemaTest.Parser.ObjectParser do
  use ExUnit.Case
  doctest JsonSchema.Parser.ObjectParser, import: true

  alias JsonSchema.{Parser, Types}
  alias Parser.{ObjectParser, ParserError}
  alias Types.{ObjectType, PrimitiveType, TypeReference}

  test "can parse correct object type" do
    parser_result =
      ~S"""
      {
        "type": "object",
        "properties": {
          "color": {
            "$ref": "#/definitions/color"
          },
          "title": {
            "type": "string"
          },
          "radius": {
            "type": "number"
          }
        },
        "patternProperties": {
          "f.*o": {
            "type": "integer"
          }
        },
        "additionalProperties": {
          "type": "boolean"
        },
        "required": ["color", "radius"]
      }
      """
      |> Jason.decode!()
      |> ObjectParser.parse(nil, nil, ["#", "circle"], "circle")

    expected_object_type = %ObjectType{
      name: "circle",
      path: ["#", "circle"],
      required: ["color", "radius"],
      properties: %{
        "color" => ["#", "circle", "properties", "color"],
        "title" => ["#", "circle", "properties", "title"],
        "radius" => ["#", "circle", "properties", "radius"]
      },
      pattern_properties: %{
        "f.*o" => ["#", "circle", "patternProperties", "f.*o"]
      },
      additional_properties: ["#", "circle", "additionalProperties"]
    }

    expected_color_type_reference = %TypeReference{
      name: "color",
      path: ["#", "definitions", "color"]
    }

    expected_regex_primitive_type = %PrimitiveType{
      name: "f.*o",
      path: ["#", "circle", "patternProperties", "f.*o"],
      type: "integer"
    }

    expected_title_primitive_type = %PrimitiveType{
      name: "title",
      path: ["#", "circle", "properties", "title"],
      type: "string"
    }

    expected_radius_primitive_type = %PrimitiveType{
      name: "radius",
      path: ["#", "circle", "properties", "radius"],
      type: "number"
    }

    expected_additional_properties_type = %PrimitiveType{
      name: "additionalProperties",
      path: ["#", "circle", "additionalProperties"],
      type: "boolean"
    }

    assert parser_result.errors == []
    assert parser_result.warnings == []

    assert parser_result.type_dict == %{
             "#/circle" => expected_object_type,
             "#/circle/properties/color" => expected_color_type_reference,
             "#/circle/properties/title" => expected_title_primitive_type,
             "#/circle/properties/radius" => expected_radius_primitive_type,
             "#/circle/patternProperties/f.*o" => expected_regex_primitive_type,
             "#/circle/additionalProperties" => expected_additional_properties_type
           }
  end

  test "returns error when parsing invalid patternProperties" do
    parser_result =
      ~S"""
      {
        "type": "object",
        "properties": {
          "color": {
            "$ref": "#/definitions/color"
          },
          "title": {
            "type": "string"
          },
          "radius": {
            "type": "number"
          }
        },
        "patternProperties": {
          "*foo": {
            "type": "integer"
          }
        },
        "additionalProperties": {
            "type": "boolean"
        },
        "required": ["color", "radius"]
      }
      """
      |> Jason.decode!()
      |> ObjectParser.parse(nil, nil, ["#", "circle"], "circle")

    assert parser_result.warnings == []

    %ParserError{
      error_type: :name_not_a_regex,
      identifier: "#/circle/patternProperties",
      message: msg
    } = Enum.fetch!(parser_result.errors, 0)

    assert String.contains?(msg, "into a valid Regular Expression")
  end
end
