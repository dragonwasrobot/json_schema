# JSON Schema

[![Build Status](https://travis-ci.org/dragonwasrobot/json_schema.svg?branch=master)](https://travis-ci.org/dragonwasrobot/json_schema)
[![Module Version](https://img.shields.io/hexpm/v/json_schema.svg)](https://hex.pm/packages/json_schema)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/json_schema/)
[![License](https://img.shields.io/hexpm/l/json_schema.svg)](https://github.com/dragonwasrobot/json_schema/blob/master/LICENSE)

A JSON schema parser for inspection and manipulation of JSON Schema Abstract
Syntax Trees (ASTs). This library is meant as a basis for writing other
libraries or tools that need to use JSON schema documents. For example, a JSON
schema validator that validates a JSON object according to a JSON schema
specification, or a code generator that generates a data model and accompanying
JSON serializers based on the JSON schema specification of an API -- the project
[JSON Schema to Elm](https://github.com/dragonwasrobot/json-schema-to-elm) is an
example of such a tool.

## Installation

Add `:json_schema` as a dependency in `mix.exs`:

```elixir
defp deps do
  [
    {:json_schema, "~> 0.4"}
  ]
end
```

## Usage

> The words *type* and *subschema* are used interchangeable in the rest of
> the document.

The main API entry point is the `JsonSchema` module, which supports parsing a
list of JSON schema files into JSON Schema ASTs via `parse_schema_files`, or
resolving a JSON schema type given an identifier via `resolve_type`.

### Parsing a JSON schema file into an Abstract Syntax Tree

Presuming we have the following two JSON schema files:

```json
{
    "$schema": "http://json-schema.org/draft-07/schema#",
    "$id": "http://example.com/circle.json",
    "title": "Circle",
    "description": "Schema for a circle shape",
    "type": "object",
    "properties": {
        "center": {
            "$ref": "http://example.com/definitions.json#point"
        },
        "radius": {
            "type": "number"
        },
        "color": {
            "$ref": "http://example.com/definitions.json#color"
        }
    },
    "required": ["center", "radius"]
}
```

and

```json
{
    "$schema": "http://json-schema.org/draft-07/schema#",
    "title": "Definitions",
    "$id": "http://example.com/definitions.json",
    "description": "Schema for common types",
    "definitions": {
        "color": {
            "$id": "#color",
            "type": "string",
            "enum": [ "red", "yellow", "green", "blue" ]
        },
        "point": {
            "$id": "#point",
            "type": "object",
            "properties": {
                "x": {
                    "type": "number"
                },
                "y": {
                    "type": "number"
                }
            },
            "required": [ "x", "y" ]
        }
    }
}
```

we can parses the into a JSON schema AST by passing them to
`JsonSchema.parse_schema_files`. This produces a `SchemaResult` containing a
schema dictionary, `schema_dict`, and any errors or warnings generated along the
way.

```elixir
schema_paths = ["./path/to/json_schemas/circle.json",
                "./path/to/json_schemas/definitions.json"
               ]
schema_result = JsonSchema.parse_schema_files(schema_paths)
%JsonSchema.Parser.SchemaResult{
  errors: [],
  warnings: [],
  schema_dict: %{
    "http://example.com/circle.json" => %JsonSchema.Types.SchemaDefinition{
      description: "Schema for a circle shape",
      file_path: "/path/to/json-schemas/circle.json",
      id: URI.parse("http://example.com/circle.json"),
      title: "Circle",
      types: %{
        "#" => %JsonSchema.Types.ObjectType{
          additional_properties: nil,
          description: "Schema for a circle shape",
          name: "Circle",
          path: URI.parse("#"),
          pattern_properties: %{},
          properties: %{
            "center" => URI.parse("#/properties/center"),
            "color" => URI.parse("#/properties/color"),
            "radius" => URI.parse("#/properties/radius")
          },
          required: ["center", "radius"]
        },
        "#/properties/center" => %JsonSchema.Types.TypeReference{
          name: "center",
          path: URI.parse("http://example.com/definitions.json#point")
        },
        "#/properties/color" => %JsonSchema.Types.TypeReference{
          name: "color",
          path: URI.parse("http://example.com/definitions.json#color")
        },
        "#/properties/radius" => %JsonSchema.Types.PrimitiveType{
          description: nil,
          name: "radius",
          path: URI.parse("#/properties/radius),
          type: :number
        },
        "http://example.com/circle.json#" => %JsonSchema.Types.ObjectType{
          additional_properties: nil,
          description: "Schema for a circle shape",
          name: "Circle",
          path: URI.parse("#"),
          pattern_properties: %{},
          properties: %{
            "center" => URI.parse("#/properties/center"),
            "color" => URI.parse("#/properties/color"),
            "radius" => URI.parse("#/properties/radius")
          },
          required: ["center", "radius"]
        }
      }
    },
    "http://example.com/definitions.json" => %JsonSchema.Types.SchemaDefinition{
      description: "Schema for common types",
      file_path: "/path/to/json-schemas/definitions.json",
      id: URI.parse("http://example.com/definitions.json"),
      title: "Definitions",
      types: %{
        "#/definitions/color" => %JsonSchema.Types.EnumType{
          description: nil,
          name: "color",
          path: URI.parse("#/definitions/color"),
          type: :string,
          values: ["red", "yellow", "green", "blue"]
        },
        "#/definitions/point" => %JsonSchema.Types.ObjectType{
          additional_properties: nil,
          description: nil,
          name: "point",
          path: URI.parse("#/definitions/point"),
          pattern_properties: %{},
          properties: %{
            "x" => URI.parse("#/definitions/point/properties/x"),
            "y" => URI.parse("#/definitions/point/properties/y")
          },
          required: ["x", "y"]
        },
        "#/definitions/point/properties/x" => %JsonSchema.Types.PrimitiveType{
          description: nil,
          name: "x",
          path: URI.parse("/definitions/point/properties/x"),
          type: :number
        },
        "#/definitions/point/properties/y" => %JsonSchema.Types.PrimitiveType{
          description: nil,
          name: "y",
          path: URI.parse("#/definitions/point/properties/y"),
          type: :number
        },
        "http://example.com/definitions.json#color" => %JsonSchema.Types.EnumType{
          description: nil,
          name: "color",
          path: URI.parse("#/definitions/color"),
          type: :string,
          values: ["red", "yellow", "green", "blue"]
        },
        "http://example.com/definitions.json#point" => %JsonSchema.Types.ObjectType{
          additional_properties: nil,
          description: nil,
          name: "point",
          path: URI.parse("#/definitions/point"),
          pattern_properties: %{},
          properties: %{
            "x" => URI.parse("#/definitions/point/properties/x"),
            "y" => URI.parse("#/definitions/point/properties/y")
          },
          required: ["x", "y"]
        }
      }
    }
  }
}
```

The schema dictionary uses the schema ID (`URI`) as key and the parsed schema as
value. Each parsed schema likewise contains a type dictionary, `types`, which
uses the subschema path (`URI`) as key and the parsed subschema as value.

If there are no errors in the schema result, the parsed schema dictionary can
then be used in your own JSON schema tool as appropriate.

### Resolving a JSON Schema type from an identifier

Using the example schema dictionary from the previous section, we can use the
`JsonSchema.resolve_type` function to lookup a subschema associated contained
the schema dictionary. The `resolve_type` function expects:

- the `identifier` of the subschema to lookup which can be either a fully
  qualified identifier like `http://example.com/definitions.json#color`, a
  relative identifier like `#color`, or a relative path like
  `#/definitions/color` when resolving a subschema inside the same parent
  schema.
- the `parent` identifier of the subschema doing the lookup, needed for relative
  lookups and better error messaging,
- the enclosing schema definition, `schema_def`, of the subschema doing the
  lookup, also needed for relative lookups and error messaging,
- the `schema dictionary` of the whole set of schemas.

In the example below, we resolve the reference to `color`:

```json
"color": {
  "$ref": "http://example.com/definitions.json#color"
}
```

from the inside the `circle` subschema properties.

```elixir
schema_dict = schema_result.schema_dict
schema_def = schema_dict["http://example.com/circle.json"]
parent = URI.parse("#/properties")
identifier = URI.parse("#/properties/color")
lookup_result = JsonSchema.resolve_type(identifier, parent, schema_def, schema_dict)
{:ok, {color_type, parent_schema_def}} = lookup_result
parent_schema_def == schema_dict["http://example.com/circle.json"]
color_type
%JsonSchema.Types.EnumType{
    description: nil,
    name: "color",
    path: URI.parse("#/definitions/color"),
    type: :string,
    values: ["red", "yellow", "green", "blue"]
  }
```
