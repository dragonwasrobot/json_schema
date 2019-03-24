defmodule JsonSchemaTest.Parser.AllOfParser do
  use ExUnit.Case
  doctest JsonSchema.Parser.AllOfParser, import: true

  require Logger
  alias JsonSchema.{Parser, Types}
  alias Parser.AllOfParser
  alias Types.{AllOfType, ObjectType, PrimitiveType, TypeReference}

  defp all_of_type do
    """
    {
      "allOf": [
        {
          "type": "object",
          "properties": {
            "color": {
              "$ref": "#/definitions/color"
            },
            "description": {
              "type": "string"
            }
          },
          "required": [ "color" ]
        },
        {
          "$ref": "#/definitions/circle"
        }
      ]
    }
    """
  end

  defp parent_id, do: "http://www.example.com/schemas/fancyCircle.json"
  defp id, do: nil
  defp path, do: "#/definitions/fancyCircle"
  defp name, do: "fancyCircle"

  test "can parse all_of type" do
    parser_result =
      all_of_type()
      |> Jason.decode!()
      |> AllOfParser.parse(parent_id(), id(), URI.parse(path()), name())

    expected_all_of_type = %AllOfType{
      name: "fancyCircle",
      path: URI.parse(path()),
      types: [
        URI.parse(Path.join(path(), "allOf/0")),
        URI.parse(Path.join(path(), "allOf/1"))
      ]
    }

    expected_object_type = %ObjectType{
      name: "0",
      path: URI.parse(Path.join(path(), "allOf/0")),
      required: ["color"],
      properties: %{
        "color" => URI.parse(Path.join(path(), "allOf/0/properties/color")),
        "description" => URI.parse(Path.join(path(), "allOf/0/properties/description"))
      },
      pattern_properties: %{},
      additional_properties: nil
    }

    expected_color_type = %TypeReference{
      name: "color",
      path: URI.parse("#/definitions/color")
    }

    expected_description_type = %PrimitiveType{
      name: "description",
      path: URI.parse(Path.join(path(), "allOf/0/properties/description")),
      type: "string"
    }

    expected_circle_type = %TypeReference{
      name: "1",
      path: URI.parse("#/definitions/circle")
    }

    assert parser_result.errors == []
    assert parser_result.warnings == []

    assert parser_result.type_dict == %{
             "#/definitions/fancyCircle" => expected_all_of_type,
             "#/definitions/fancyCircle/allOf/0" => expected_object_type,
             "#/definitions/fancyCircle/allOf/0/properties/color" => expected_color_type,
             "#/definitions/fancyCircle/allOf/0/properties/description" =>
               expected_description_type,
             "#/definitions/fancyCircle/allOf/1" => expected_circle_type
           }
  end
end
