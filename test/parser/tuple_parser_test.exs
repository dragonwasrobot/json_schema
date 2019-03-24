defmodule JsonSchemaTest.Parser.TupleParser do
  use ExUnit.Case
  doctest JsonSchema.Parser.TupleParser, import: true

  alias JsonSchema.{Parser, Types}
  alias Parser.TupleParser
  alias Types.{TupleType, TypeReference}

  test "parse tuple type" do
    parser_result =
      """
      {
        "type": "array",
        "items": [
          { "$ref": "#/definitions/rectangle" },
          { "$ref": "#/definitions/circle" }
        ]
      }
      """
      |> Jason.decode!()
      |> TupleParser.parse(nil, nil, URI.parse("#/shapePair"), "shapePair")

    expected_tuple_type = %TupleType{
      name: "shapePair",
      path: URI.parse("#/shapePair"),
      items: [
        URI.parse("#/shapePair/items/0"),
        URI.parse("#/shapePair/items/1")
      ]
    }

    expected_rectangle_type_reference = %TypeReference{
      name: "0",
      path: URI.parse("#/definitions/rectangle")
    }

    expected_circle_type_reference = %TypeReference{
      name: "1",
      path: URI.parse("#/definitions/circle")
    }

    assert parser_result.errors == []
    assert parser_result.warnings == []

    assert parser_result.type_dict == %{
             "#/shapePair" => expected_tuple_type,
             "#/shapePair/items/0" => expected_rectangle_type_reference,
             "#/shapePair/items/1" => expected_circle_type_reference
           }
  end
end
