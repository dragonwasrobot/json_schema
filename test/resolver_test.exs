defmodule JsonSchemaTest.Resolver do
  use ExUnit.Case
  doctest JsonSchema.Resolver, import: true

  require Logger
  alias JsonSchema.{Resolver, Types}
  alias Types.{EnumType, PrimitiveType, SchemaDefinition}

  test "can resolve type with URI fragment identifier" do
    id = URI.parse("#/properties/color")
    parent_id = URI.parse("#/properties")

    enum_type = %EnumType{
      name: "color",
      path: URI.parse("#/properties/color"),
      type: "string",
      values: ["none", "green", "yellow", "red"]
    }

    primitive_type1 = %PrimitiveType{
      name: "title",
      path: URI.parse("#/properties/title"),
      type: "string"
    }

    primitive_type2 = %PrimitiveType{
      name: "radius",
      path: URI.parse("#/properties/radius"),
      type: "number"
    }

    schema_def = %SchemaDefinition{
      description: "Test schema",
      id: URI.parse("http://example.com/test.json"),
      title: "Test",
      types: %{
        "#/properties/color" => enum_type,
        "#/properties/title" => primitive_type1,
        "#/properties/radius" => primitive_type2
      }
    }

    schema_dict = %{"http://example.com/test.json" => schema_def}

    {:ok, {^enum_type, ^schema_def}} =
      Resolver.resolve_type(id, parent_id, schema_def, schema_dict)
  end

  test "can resolve type with fully qualified URI identifier" do
    id = URI.parse("http://example.com/test.json#/properties/color")
    parent_id = URI.parse("http://example.com/test.json#/properties")

    enum_type = %EnumType{
      name: "color",
      path: URI.parse("#/properties/color"),
      type: "string",
      values: ["none", "green", "yellow", "red"]
    }

    primitive_type1 = %PrimitiveType{
      name: "title",
      path: URI.parse("#/properties/title"),
      type: "string"
    }

    primitive_type2 = %PrimitiveType{
      name: "radius",
      path: URI.parse("#/properties/radius"),
      type: "number"
    }

    schema_def = %SchemaDefinition{
      description: "Test schema",
      id: URI.parse("http://example.com/test.json"),
      title: "Test",
      types: %{
        "#/properties/color" => enum_type,
        "#/properties/title" => primitive_type1,
        "#/properties/radius" => primitive_type2
      }
    }

    schema_dict = %{"http://example.com/test.json" => schema_def}

    {:ok, {^enum_type, ^schema_def}} =
      Resolver.resolve_type(id, parent_id, schema_def, schema_dict)
  end
end
