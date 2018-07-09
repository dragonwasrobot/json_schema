defmodule JS2ETest.Printer.ExternalReferences do
  use ExUnit.Case

  require Logger
  alias JS2E.{Printer, Types}

  alias Types.{
    EnumType,
    ObjectType,
    PrimitiveType,
    SchemaDefinition,
    TypeReference
  }

  test "prints external references in generated code" do
    schema_result =
      Printer.print_schemas(schema_representations(), module_name())

    file_dict = schema_result.file_dict
    circle_program = file_dict["./js2e_output/Data/Circle.elm"]

    assert circle_program ==
             """
             module Data.Circle exposing (..)

             -- Schema for a circle shape

             import Json.Decode as Decode
                 exposing
                     ( succeed
                     , fail
                     , map
                     , maybe
                     , field
                     , index
                     , at
                     , andThen
                     , oneOf
                     , nullable
                     , Decoder
                     )
             import Json.Decode.Pipeline
                 exposing
                     ( decode
                     , required
                     , optional
                     , custom
                     )
             import Json.Encode as Encode
                 exposing
                     ( Value
                     , object
                     , list
                     )
             import Data.Definitions as Definitions


             type alias Circle =
                 { center : Definitions.Point
                 , color : Maybe Definitions.Color
                 , radius : Float
                 }


             circleDecoder : Decoder Circle
             circleDecoder =
                 decode Circle
                     |> required "center" Definitions.pointDecoder
                     |> optional "color" (nullable Definitions.colorDecoder) Nothing
                     |> required "radius" Decode.float


             encodeCircle : Circle -> Value
             encodeCircle circle =
                 let
                     center =
                         [ ( "center", Definitions.encodePoint circle.center ) ]

                     color =
                         case circle.color of
                             Just color ->
                                 [ ( "color", Definitions.encodeColor color ) ]

                             Nothing ->
                                 []

                     radius =
                         [ ( "radius", Encode.float circle.radius ) ]
                 in
                     object <|
                         center ++ color ++ radius
             """

    definitions_program = file_dict["./js2e_output/Data/Definitions.elm"]

    assert definitions_program ==
             """
             module Data.Definitions exposing (..)

             -- Schema for common types

             import Json.Decode as Decode
                 exposing
                     ( succeed
                     , fail
                     , map
                     , maybe
                     , field
                     , index
                     , at
                     , andThen
                     , oneOf
                     , nullable
                     , Decoder
                     )
             import Json.Decode.Pipeline
                 exposing
                     ( decode
                     , required
                     , optional
                     , custom
                     )
             import Json.Encode as Encode
                 exposing
                     ( Value
                     , object
                     , list
                     )


             type Color
                 = Red
                 | Yellow
                 | Green
                 | Blue


             type alias Point =
                 { x : Float
                 , y : Float
                 }


             colorDecoder : Decoder Color
             colorDecoder =
                 Decode.string
                     |> andThen
                         (\\color ->
                             case color of
                                 "red" ->
                                     succeed Red

                                 "yellow" ->
                                     succeed Yellow

                                 "green" ->
                                     succeed Green

                                 "blue" ->
                                     succeed Blue

                                 _ ->
                                     fail <| "Unknown color type: " ++ color
                         )


             pointDecoder : Decoder Point
             pointDecoder =
                 decode Point
                     |> required "x" Decode.float
                     |> required "y" Decode.float


             encodeColor : Color -> Value
             encodeColor color =
                 case color of
                     Red ->
                         Encode.string "red"

                     Yellow ->
                         Encode.string "yellow"

                     Green ->
                         Encode.string "green"

                     Blue ->
                         Encode.string "blue"


             encodePoint : Point -> Value
             encodePoint point =
                 let
                     x =
                         [ ( "x", Encode.float point.x ) ]

                     y =
                         [ ( "y", Encode.float point.y ) ]
                 in
                     object <|
                         x ++ y
             """
  end

  test "prints external references in generated tests" do
    schema_tests_result =
      Printer.print_schemas_tests(schema_representations(), module_name())

    file_dict = schema_tests_result.file_dict
    circle_tests = file_dict["./js2e_output/tests/Data/CircleTests.elm"]

    assert circle_tests ==
             """
             module Data.CircleTests exposing (..)

             -- Tests: Schema for a circle shape

             import Expect exposing (Expectation)
             import Fuzz exposing (Fuzzer)
             import Test exposing (..)
             import Json.Decode as Decode
             import Data.Circle exposing (..)
             import Data.DefinitionsTests as Definitions


             circleFuzzer : Fuzzer Circle
             circleFuzzer =
                 Fuzz.map3
                     Circle
                     Definitions.pointFuzzer
                     (Fuzz.maybe Definitions.colorFuzzer)
                     Fuzz.float


             encodeDecodeCircleTest : Test
             encodeDecodeCircleTest =
                 fuzz circleFuzzer "can encode and decode Circle object" <|
                     \\circle ->
                         circle
                             |> encodeCircle
                             |> Decode.decodeValue circleDecoder
                             |> Expect.equal (Ok circle)
             """

    definitions_tests =
      file_dict["./js2e_output/tests/Data/DefinitionsTests.elm"]

    assert definitions_tests ==
             """
             module Data.DefinitionsTests exposing (..)

             -- Tests: Schema for common types

             import Expect exposing (Expectation)
             import Fuzz exposing (Fuzzer)
             import Test exposing (..)
             import Json.Decode as Decode
             import Data.Definitions exposing (..)


             colorFuzzer : Fuzzer Color
             colorFuzzer =
                 Fuzz.oneOf
                     [ Fuzz.constant Red
                     , Fuzz.constant Yellow
                     , Fuzz.constant Green
                     , Fuzz.constant Blue
                     ]


             encodeDecodeColorTest : Test
             encodeDecodeColorTest =
                 fuzz colorFuzzer "can encode and decode Color object" <|
                     \\color ->
                         color
                             |> encodeColor
                             |> Decode.decodeValue colorDecoder
                             |> Expect.equal (Ok color)


             pointFuzzer : Fuzzer Point
             pointFuzzer =
                 Fuzz.map2
                     Point
                     Fuzz.float
                     Fuzz.float


             encodeDecodePointTest : Test
             encodeDecodePointTest =
                 fuzz pointFuzzer "can encode and decode Point object" <|
                     \\point ->
                         point
                             |> encodePoint
                             |> Decode.decodeValue pointDecoder
                             |> Expect.equal (Ok point)
             """
  end

  defp module_name, do: "Data"
  defp definitions_schema_id, do: "http://example.com/definitions.json"
  defp circle_schema_id, do: "http://example.com/circle.json"

  defp schema_representations,
    do: %{
      definitions_schema_id() => %SchemaDefinition{
        description: "Schema for common types",
        id: URI.parse(definitions_schema_id()),
        title: "Definitions",
        types: %{
          "#/definitions/color" => %EnumType{
            name: "color",
            path: ["#", "definitions", "color"],
            type: "string",
            values: ["red", "yellow", "green", "blue"]
          },
          "#/definitions/point" => %ObjectType{
            name: "point",
            path: ["#", "definitions", "point"],
            properties: %{
              "x" => ["#", "definitions", "point", "x"],
              "y" => ["#", "definitions", "point", "y"]
            },
            required: ["x", "y"]
          },
          "#/definitions/point/x" => %PrimitiveType{
            name: "x",
            path: ["#", "definitions", "point", "x"],
            type: "number"
          },
          "#/definitions/point/y" => %PrimitiveType{
            name: "y",
            path: ["#", "definitions", "point", "y"],
            type: "number"
          },
          "http://example.com/definitions.json#color" => %EnumType{
            name: "color",
            path: ["#", "definitions", "color"],
            type: "string",
            values: ["red", "yellow", "green", "blue"]
          },
          "http://example.com/definitions.json#point" => %ObjectType{
            name: "point",
            path: ["#", "definitions", "point"],
            properties: %{
              "x" => ["#", "definitions", "point", "x"],
              "y" => ["#", "definitions", "point", "y"]
            },
            required: ["x", "y"]
          }
        }
      },
      circle_schema_id() => %SchemaDefinition{
        id: URI.parse(circle_schema_id()),
        title: "Circle",
        description: "Schema for a circle shape",
        types: %{
          "#" => %ObjectType{
            name: "circle",
            path: ["#"],
            properties: %{
              "center" => ["#", "center"],
              "color" => ["#", "color"],
              "radius" => ["#", "radius"]
            },
            required: ["center", "radius"]
          },
          "#/center" => %TypeReference{
            name: "center",
            path: URI.parse("http://example.com/definitions.json#point")
          },
          "#/color" => %TypeReference{
            name: "color",
            path: URI.parse("http://example.com/definitions.json#color")
          },
          "#/radius" => %PrimitiveType{
            name: "radius",
            path: ["#", "radius"],
            type: "number"
          },
          "http://example.com/circle.json#" => %ObjectType{
            name: "circle",
            path: "#",
            properties: %{
              "center" => ["#", "center"],
              "color" => ["#", "color"],
              "radius" => ["#", "radius"]
            },
            required: ["center", "radius"]
          }
        }
      }
    }
end
