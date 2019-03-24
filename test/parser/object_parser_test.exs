defmodule JsonSchemaTest.Parser.ObjectParser do
  use ExUnit.Case
  doctest JsonSchema.Parser.ObjectParser, import: true

  alias JsonSchema.{Parser, Types}
  alias Parser.{ObjectParser, ParserError}
  alias Types.{ObjectType, PrimitiveType, TypeReference}

  test "can parse correct object type" do
    parser_result =
      """
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
      |> ObjectParser.parse(nil, nil, URI.parse("#/circle"), "circle")

    expected_object_type = %ObjectType{
      name: "circle",
      path: URI.parse("#/circle"),
      required: ["color", "radius"],
      properties: %{
        "color" => URI.parse("#/circle/properties/color"),
        "title" => URI.parse("#/circle/properties/title"),
        "radius" => URI.parse("#/circle/properties/radius")
      },
      pattern_properties: %{
        "f.*o" => URI.parse("#/circle/patternProperties/f.*o")
      },
      additional_properties: URI.parse("#/circle/additionalProperties")
    }

    expected_color_type_reference = %TypeReference{
      name: "color",
      path: URI.parse("#/definitions/color")
    }

    expected_regex_primitive_type = %PrimitiveType{
      name: "f.*o",
      path: URI.parse("#/circle/patternProperties/f.*o"),
      type: "integer"
    }

    expected_title_primitive_type = %PrimitiveType{
      name: "title",
      path: URI.parse("#/circle/properties/title"),
      type: "string"
    }

    expected_radius_primitive_type = %PrimitiveType{
      name: "radius",
      path: URI.parse("#/circle/properties/radius"),
      type: "number"
    }

    expected_additional_properties_type = %PrimitiveType{
      name: "additionalProperties",
      path: URI.parse("#/circle/additionalProperties"),
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
      """
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
      |> ObjectParser.parse(nil, nil, URI.parse("#/circle"), "circle")

    assert parser_result.warnings == []

    %ParserError{
      error_type: :name_not_a_regex,
      identifier: "#/circle/patternProperties",
      message: msg
    } = Enum.fetch!(parser_result.errors, 0)

    assert String.contains?(msg, "into a valid Regular Expression")
  end
end
