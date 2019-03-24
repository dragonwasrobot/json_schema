defmodule JsonSchemaTest.Parser.OneOfParser do
  use ExUnit.Case
  doctest JsonSchema.Parser.OneOfParser, import: true

  alias JsonSchema.{Parser, Types}
  alias Parser.OneOfParser
  alias Types.{ObjectType, OneOfType, PrimitiveType, TypeReference}

  test "parse primitive one_of type" do
    parser_result =
      """
      {
        "oneOf": [
          {
            "type": "object",
            "properties": {
              "color": {
                "$ref": "#/color"
              },
              "title": {
                "type": "string"
              },
              "radius": {
                "type": "number"
              }
            },
            "required": [ "color", "radius" ]
          },
          {
            "type": "string"
          }
        ]
      }
      """
      |> Jason.decode!()
      |> OneOfParser.parse(nil, nil, URI.parse("#/schema"), "schema")

    expected_object_type = %ObjectType{
      name: "0",
      path: URI.parse("#/schema/oneOf/0"),
      required: ["color", "radius"],
      properties: %{
        "color" => URI.parse("#/schema/oneOf/0/properties/color"),
        "title" => URI.parse("#/schema/oneOf/0/properties/title"),
        "radius" => URI.parse("#/schema/oneOf/0/properties/radius")
      },
      pattern_properties: %{},
      additional_properties: nil
    }

    expected_primitive_type = %PrimitiveType{
      name: "1",
      path: URI.parse("#/schema/oneOf/1"),
      type: "string"
    }

    expected_color_type = %TypeReference{
      name: "color",
      path: URI.parse("#/color")
    }

    expected_radius_type = %PrimitiveType{
      name: "radius",
      path: URI.parse("#/schema/oneOf/0/properties/radius"),
      type: "number"
    }

    expected_title_type = %PrimitiveType{
      name: "title",
      path: URI.parse("#/schema/oneOf/0/properties/title"),
      type: "string"
    }

    expected_one_of_type = %OneOfType{
      name: "schema",
      path: URI.parse("#/schema"),
      types: [
        URI.parse("#/schema/oneOf/0"),
        URI.parse("#/schema/oneOf/1")
      ]
    }

    assert parser_result.errors == []
    assert parser_result.warnings == []

    assert parser_result.type_dict == %{
             "#/schema" => expected_one_of_type,
             "#/schema/oneOf/0" => expected_object_type,
             "#/schema/oneOf/1" => expected_primitive_type,
             "#/schema/oneOf/0/properties/color" => expected_color_type,
             "#/schema/oneOf/0/properties/radius" => expected_radius_type,
             "#/schema/oneOf/0/properties/title" => expected_title_type
           }
  end
end
