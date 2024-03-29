defmodule JsonSchemaTest.Parser.AnyOfParser do
  use ExUnit.Case
  doctest JsonSchema.Parser.AnyOfParser, import: true

  alias JsonSchema.{Parser, Types}
  alias Parser.AnyOfParser
  alias Types.{AnyOfType, ObjectType, PrimitiveType, TypeReference}

  test "parse primitive any_of type" do
    parent = "http://www.example.com/schema.json"

    parser_result =
      """
      {
        "anyOf": [
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
            "required": [ "color", "radius" ]
          },
          {
            "type": "string"
          }
        ]
      }
      """
      |> Jason.decode!()
      |> AnyOfParser.parse(parent, nil, URI.parse("#/schema"), "schema")

    expected_object_type = %ObjectType{
      name: :anonymous,
      path: URI.parse("#/schema/anyOf/0"),
      required: ["color", "radius"],
      properties: %{
        "color" => URI.parse("#/schema/anyOf/0/properties/color"),
        "title" => URI.parse("#/schema/anyOf/0/properties/title"),
        "radius" => URI.parse("#/schema/anyOf/0/properties/radius")
      },
      pattern_properties: %{},
      additional_properties: nil
    }

    expected_primitive_type = %PrimitiveType{
      name: :anonymous,
      path: URI.parse("#/schema/anyOf/1"),
      type: :string
    }

    expected_color_type = %TypeReference{
      name: "color",
      path: URI.parse("#/definitions/color")
    }

    expected_radius_type = %PrimitiveType{
      name: "radius",
      path: URI.parse("#/schema/anyOf/0/properties/radius"),
      type: :number
    }

    expected_title_type = %PrimitiveType{
      name: "title",
      path: URI.parse("#/schema/anyOf/0/properties/title"),
      type: :string
    }

    expected_any_of_type = %AnyOfType{
      name: "schema",
      path: URI.parse("#/schema"),
      types: [
        URI.parse("#/schema/anyOf/0"),
        URI.parse("#/schema/anyOf/1")
      ]
    }

    assert parser_result.errors == []
    assert parser_result.warnings == []

    assert parser_result.type_dict == %{
             "#/schema" => expected_any_of_type,
             "#/schema/anyOf/0" => expected_object_type,
             "#/schema/anyOf/1" => expected_primitive_type,
             "#/schema/anyOf/0/properties/color" => expected_color_type,
             "#/schema/anyOf/0/properties/radius" => expected_radius_type,
             "#/schema/anyOf/0/properties/title" => expected_title_type
           }
  end
end
