defmodule JsonSchemaTest.Parser.TypeReferenceParser do
  use ExUnit.Case
  doctest JsonSchema.Parser.TypeReferenceParser, import: true

  alias JsonSchema.{Parser, Types}
  alias Parser.TypeReferenceParser
  alias Types.TypeReference

  test "parse type reference" do
    parser_result =
      """
      {
        "$ref": "#/definitions/targetTypeId"
      }
      """
      |> Jason.decode!()
      |> TypeReferenceParser.parse(nil, nil, URI.parse("#/typeRef"), "typeRef")

    expected_type_reference = %TypeReference{
      name: "typeRef",
      path: URI.parse("#/definitions/targetTypeId")
    }

    assert parser_result.errors == []
    assert parser_result.warnings == []

    assert parser_result.type_dict == %{
             "#/typeRef" => expected_type_reference
           }
  end
end
