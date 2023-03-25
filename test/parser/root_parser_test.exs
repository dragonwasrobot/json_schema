defmodule JsonSchemaTest.Parser.RootParser do
  use ExUnit.Case

  alias JsonSchema.Parser.{RootParser, SchemaResult}

  alias JsonSchema.Types.{
    ArrayType,
    ObjectType,
    PrimitiveType,
    SchemaDefinition
  }

  doctest RootParser, import: true

  test "can parse root object with nested children" do
    parser_result =
      """
          {
            "$schema": "http://json-schema.org/draft-07/schema#",
            "$id": "http://example.com/root.json",
            "type": "object",
            "title": "The Root Schema",
            "description": "An explanation about the purpose of this instance.",
            "required": [
              "checked",
              "dimensions",
              "id",
              "name",
              "price",
              "tags"
            ],
            "properties": {
              "checked": {
                "$id": "#/properties/checked",
                "type": "boolean",
                "title": "The Checked Schema",
                "description": "An explanation about the purpose of this instance."
              },
              "dimensions": {
                "$id": "#/properties/dimensions",
                "type": "object",
                "title": "The Dimensions Schema",
                "description": "An explanation about the purpose of this instance.",
                "required": [
                  "width",
                  "height"
                ],
                "properties": {
                  "width": {
                    "$id": "#/properties/dimensions/properties/width",
                    "type": "integer",
                    "title": "The Width Schema",
                    "description": "An explanation about the purpose of this instance."
                  },
                  "height": {
                    "$id": "#/properties/dimensions/properties/height",
                    "type": "integer",
                    "title": "The Height Schema",
                    "description": "An explanation about the purpose of this instance."
                  }
                }
              },
              "id": {
                "$id": "#/properties/id",
                "type": "integer",
                "title": "The Id Schema",
                "description": "An explanation about the purpose of this instance."
              },
              "name": {
                "$id": "#/properties/name",
                "type": "string",
                "title": "The Name Schema",
                "description": "An explanation about the purpose of this instance.",
                "pattern": "^(.*)$"
              },
              "price": {
                "$id": "#/properties/price",
                "type": "number",
                "title": "The Price Schema",
                "description": "An explanation about the purpose of this instance."
              },
              "tags": {
                "$id": "#/properties/tags",
                "type": "array",
                "title": "The Tags Schema",
                "description": "An explanation about the purpose of this instance.",
                "items": {
                  "$id": "#/properties/tags/items",
                  "type": "string",
                  "title": "The Items Schema",
                  "description": "An explanation about the purpose of this instance.",
                  "pattern": "^(.*)$"
                }
              }
            }
          }
      """
      |> Jason.decode!()
      |> RootParser.parse_schema("example.json")

    # expected_schema_result

    expected_root_type = %ObjectType{
      additional_properties: nil,
      description: "An explanation about the purpose of this instance.",
      name: "The Root Schema",
      path: URI.parse("#"),
      pattern_properties: %{},
      properties: %{
        "checked" => URI.parse("#/properties/checked"),
        "dimensions" => URI.parse("#/properties/dimensions"),
        "id" => URI.parse("#/properties/id"),
        "name" => URI.parse("#/properties/name"),
        "price" => URI.parse("#/properties/price"),
        "tags" => URI.parse("#/properties/tags")
      },
      required: ["checked", "dimensions", "id", "name", "price", "tags"]
    }

    expected_checked_type = %PrimitiveType{
      description: "An explanation about the purpose of this instance.",
      name: "checked",
      path: URI.parse("#/properties/checked"),
      type: :boolean
    }

    expected_dimensions_type = %ObjectType{
      additional_properties: nil,
      description: "An explanation about the purpose of this instance.",
      name: "dimensions",
      path: URI.parse("#/properties/dimensions"),
      pattern_properties: %{},
      properties: %{
        "height" => URI.parse("#/properties/dimensions/properties/height"),
        "width" => URI.parse("#/properties/dimensions/properties/width")
      },
      required: ["width", "height"]
    }

    expected_height_type = %PrimitiveType{
      description: "An explanation about the purpose of this instance.",
      name: "height",
      path: URI.parse("#/properties/dimensions/properties/height"),
      type: :integer
    }

    expected_width_type = %PrimitiveType{
      description: "An explanation about the purpose of this instance.",
      name: "width",
      path: URI.parse("#/properties/dimensions/properties/width"),
      type: :integer
    }

    expected_id_type = %PrimitiveType{
      description: "An explanation about the purpose of this instance.",
      name: "id",
      path: URI.parse("#/properties/id"),
      type: :integer
    }

    expected_name_type = %PrimitiveType{
      description: "An explanation about the purpose of this instance.",
      name: "name",
      path: URI.parse("#/properties/name"),
      type: :string
    }

    expected_price_type = %PrimitiveType{
      description: "An explanation about the purpose of this instance.",
      name: "price",
      path: URI.parse("#/properties/price"),
      type: :number
    }

    expected_tags_type = %ArrayType{
      description: "An explanation about the purpose of this instance.",
      items: URI.parse("#/properties/tags/items"),
      name: "tags",
      path: URI.parse("#/properties/tags")
    }

    expected_items_type = %PrimitiveType{
      description: "An explanation about the purpose of this instance.",
      name: :anonymous,
      path: URI.parse("#/properties/tags/items"),
      type: :string
    }

    expected_schema_result = %SchemaResult{
      errors: [],
      schema_dict: %{
        "http://example.com/root.json" => %SchemaDefinition{
          description: "An explanation about the purpose of this instance.",
          file_path: "example.json",
          id: URI.parse("http://example.com/root.json"),
          title: "The Root Schema",
          types: %{
            "#" => expected_root_type,
            "#/properties/checked" => expected_checked_type,
            "#/properties/dimensions" => expected_dimensions_type,
            "#/properties/dimensions/properties/height" => expected_height_type,
            "#/properties/dimensions/properties/width" => expected_width_type,
            "#/properties/id" => expected_id_type,
            "#/properties/name" => expected_name_type,
            "#/properties/price" => expected_price_type,
            "#/properties/tags" => expected_tags_type,
            "#/properties/tags/items" => expected_items_type,
            "http://example.com/root.json#" => expected_root_type,
            "http://example.com/root.json#/properties/checked" => expected_checked_type,
            "http://example.com/root.json#/properties/dimensions" => expected_dimensions_type,
            "http://example.com/root.json#/properties/dimensions/properties/height" =>
              expected_height_type,
            "http://example.com/root.json#/properties/dimensions/properties/width" =>
              expected_width_type,
            "http://example.com/root.json#/properties/id" => expected_id_type,
            "http://example.com/root.json#/properties/name" => expected_name_type,
            "http://example.com/root.json#/properties/price" => expected_price_type,
            "http://example.com/root.json#/properties/tags" => expected_tags_type,
            "http://example.com/root.json#/properties/tags/items" => expected_items_type
          }
        }
      },
      warnings: []
    }

    assert parser_result.errors == []
    assert parser_result.warnings == []
    schema_dict = parser_result.schema_dict
    schema = schema_dict["http://example.com/root.json"]
    type_dict = schema.types

    assert type_dict["#/properties/tags/items"] == expected_items_type
    assert type_dict["#/properties/tags"] == expected_tags_type
    assert type_dict["#/properties/price"] == expected_price_type
    assert type_dict["#/properties/name"] == expected_name_type
    assert type_dict["#/properties/id"] == expected_id_type

    assert type_dict["#/properties/dimensions/properties/width"] ==
             expected_width_type

    assert type_dict["#/properties/dimensions/properties/height"] ==
             expected_height_type

    assert type_dict["#/properties/dimensions"] == expected_dimensions_type
    assert type_dict["#/properties/checked"] == expected_checked_type
    assert type_dict["#"] == expected_root_type
    assert expected_schema_result == parser_result
  end
end
