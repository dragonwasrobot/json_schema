defmodule JsonSchemaTest.Parser.RootParser do
  use ExUnit.Case
  alias JsonSchema.Parser.RootParser
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

    expected_root_type = %JsonSchema.Types.ObjectType{
      additional_properties: nil,
      description: "An explanation about the purpose of this instance.",
      name: "The Root Schema",
      path: %URI{
        authority: nil,
        fragment: "",
        host: nil,
        path: nil,
        port: nil,
        query: nil,
        scheme: nil,
        userinfo: nil
      },
      pattern_properties: %{},
      properties: %{
        "checked" => %URI{
          authority: nil,
          fragment: "/properties/checked",
          host: nil,
          path: nil,
          port: nil,
          query: nil,
          scheme: nil,
          userinfo: nil
        },
        "dimensions" => %URI{
          authority: nil,
          fragment: "/properties/dimensions",
          host: nil,
          path: nil,
          port: nil,
          query: nil,
          scheme: nil,
          userinfo: nil
        },
        "id" => %URI{
          authority: nil,
          fragment: "/properties/id",
          host: nil,
          path: nil,
          port: nil,
          query: nil,
          scheme: nil,
          userinfo: nil
        },
        "name" => %URI{
          authority: nil,
          fragment: "/properties/name",
          host: nil,
          path: nil,
          port: nil,
          query: nil,
          scheme: nil,
          userinfo: nil
        },
        "price" => %URI{
          authority: nil,
          fragment: "/properties/price",
          host: nil,
          path: nil,
          port: nil,
          query: nil,
          scheme: nil,
          userinfo: nil
        },
        "tags" => %URI{
          authority: nil,
          fragment: "/properties/tags",
          host: nil,
          path: nil,
          port: nil,
          query: nil,
          scheme: nil,
          userinfo: nil
        }
      },
      required: ["checked", "dimensions", "id", "name", "price", "tags"]
    }

    expected_checked_type = %JsonSchema.Types.PrimitiveType{
      description: "An explanation about the purpose of this instance.",
      name: "checked",
      path: %URI{
        authority: nil,
        fragment: "/properties/checked",
        host: nil,
        path: nil,
        port: nil,
        query: nil,
        scheme: nil,
        userinfo: nil
      },
      type: "boolean"
    }

    expected_dimensions_type = %JsonSchema.Types.ObjectType{
      additional_properties: nil,
      description: "An explanation about the purpose of this instance.",
      name: "dimensions",
      path: %URI{
        authority: nil,
        fragment: "/properties/dimensions",
        host: nil,
        path: nil,
        port: nil,
        query: nil,
        scheme: nil,
        userinfo: nil
      },
      pattern_properties: %{},
      properties: %{
        "height" => %URI{
          authority: nil,
          fragment: "/properties/dimensions/properties/height",
          host: nil,
          path: nil,
          port: nil,
          query: nil,
          scheme: nil,
          userinfo: nil
        },
        "width" => %URI{
          authority: nil,
          fragment: "/properties/dimensions/properties/width",
          host: nil,
          path: nil,
          port: nil,
          query: nil,
          scheme: nil,
          userinfo: nil
        }
      },
      required: ["width", "height"]
    }

    expected_height_type = %JsonSchema.Types.PrimitiveType{
      description: "An explanation about the purpose of this instance.",
      name: "height",
      path: %URI{
        authority: nil,
        fragment: "/properties/dimensions/properties/height",
        host: nil,
        path: nil,
        port: nil,
        query: nil,
        scheme: nil,
        userinfo: nil
      },
      type: "integer"
    }

    expected_width_type = %JsonSchema.Types.PrimitiveType{
      description: "An explanation about the purpose of this instance.",
      name: "width",
      path: %URI{
        authority: nil,
        fragment: "/properties/dimensions/properties/width",
        host: nil,
        path: nil,
        port: nil,
        query: nil,
        scheme: nil,
        userinfo: nil
      },
      type: "integer"
    }

    expected_id_type = %JsonSchema.Types.PrimitiveType{
      description: "An explanation about the purpose of this instance.",
      name: "id",
      path: %URI{
        authority: nil,
        fragment: "/properties/id",
        host: nil,
        path: nil,
        port: nil,
        query: nil,
        scheme: nil,
        userinfo: nil
      },
      type: "integer"
    }

    expected_name_type = %JsonSchema.Types.PrimitiveType{
      description: "An explanation about the purpose of this instance.",
      name: "name",
      path: %URI{
        authority: nil,
        fragment: "/properties/name",
        host: nil,
        path: nil,
        port: nil,
        query: nil,
        scheme: nil,
        userinfo: nil
      },
      type: "string"
    }

    expected_price_type = %JsonSchema.Types.PrimitiveType{
      description: "An explanation about the purpose of this instance.",
      name: "price",
      path: %URI{
        authority: nil,
        fragment: "/properties/price",
        host: nil,
        path: nil,
        port: nil,
        query: nil,
        scheme: nil,
        userinfo: nil
      },
      type: "number"
    }

    expected_tags_type = %JsonSchema.Types.ArrayType{
      description: "An explanation about the purpose of this instance.",
      items: %URI{
        authority: nil,
        fragment: "/properties/tags/items",
        host: nil,
        path: nil,
        port: nil,
        query: nil,
        scheme: nil,
        userinfo: nil
      },
      name: "tags",
      path: %URI{
        authority: nil,
        fragment: "/properties/tags",
        host: nil,
        path: nil,
        port: nil,
        query: nil,
        scheme: nil,
        userinfo: nil
      }
    }

    expected_items_type = %JsonSchema.Types.PrimitiveType{
      description: "An explanation about the purpose of this instance.",
      name: "items",
      path: %URI{
        authority: nil,
        fragment: "/properties/tags/items",
        host: nil,
        path: nil,
        port: nil,
        query: nil,
        scheme: nil,
        userinfo: nil
      },
      type: "string"
    }

    expected_schema_result = %JsonSchema.Parser.SchemaResult{
      errors: [],
      schema_dict: %{
        "http://example.com/root.json" => %JsonSchema.Types.SchemaDefinition{
          description: "An explanation about the purpose of this instance.",
          file_path: "example.json",
          id: %URI{
            authority: "example.com",
            fragment: nil,
            host: "example.com",
            path: "/root.json",
            port: 80,
            query: nil,
            scheme: "http",
            userinfo: nil
          },
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
            "http://example.com/root.json#/properties/checked" =>
              expected_checked_type,
            "http://example.com/root.json#/properties/dimensions" =>
              expected_dimensions_type,
            "http://example.com/root.json#/properties/dimensions/properties/height" =>
              expected_height_type,
            "http://example.com/root.json#/properties/dimensions/properties/width" =>
              expected_width_type,
            "http://example.com/root.json#/properties/id" => expected_id_type,
            "http://example.com/root.json#/properties/name" =>
              expected_name_type,
            "http://example.com/root.json#/properties/price" =>
              expected_price_type,
            "http://example.com/root.json#/properties/tags" =>
              expected_tags_type,
            "http://example.com/root.json#/properties/tags/items" =>
              expected_items_type
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
