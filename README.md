# JSON Schema

### Status

[![Build Status](https://travis-ci.org/dragonwasrobot/json_schema.svg?branch=master)](https://travis-ci.org/dragonwasrobot/json_schema)

A JSON schema parser written in Elixir.

JsonSchema is an Elixir library that parses JSON schema documents into Elixir
structs and allows inspection and manipulation of the parsed documents. This
library is meant as a basis for writing other libraries or tools that need to
use JSON schema documents. For example, a JSON schema validator that validates a
JSON object according to a JSON schema specification, or a code generator that
generates a data model and accompanying JSON decoders/encoders based on the JSON
schema specification of an API -- the project [JSON Schema to
Elm](https://github.com/dragonwasrobot/json-schema-to-elm) is an example of such
a tool.

## Project Setup

To use JsonSchema with your projects, edit your `mix.exs` file and add it as a
dependency.

```elixir
defp deps do
  [{:json_schema, "~> 0.2"}]
end
```
