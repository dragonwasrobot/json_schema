# JSON Schema

A JSON schema parser written in Elixir.

## Installation

*TODO*

## Error reporting

Any errors encountered by the `js2e` tool while parsing the JSON schema files or
printing the Elm code output, is reported in an Elm-like style, e.g.

```
--- UNKNOWN NODE TYPE -------------------------------------- all_of_example.json

The value of "type" at '#/allOf/0/properties/description' did not match a known node type

    "type": "strink"
            ^^^^^^^^

Was expecting one of the following types

    ["null", "boolean", "object", "array", "number", "integer", "string"]

Hint: See the specification section 6.25. "Validation keywords - type"
<http://json-schema.org/latest/json-schema-validation.html#rfc.section.6.25>
```

or

```
--- UNRESOLVED REFERENCE ----------------------------------- all_of_example.json


The following reference at `#/allOf/0/color` could not be resolved

    "$ref": #/definitions/kolor
            ^^^^^^^^^^^^^^^^^^^


Hint: See the specification section 9. "Base URI and dereferencing"
<http://json-schema.org/latest/json-schema-core.html#rfc.section.9>
```

If you encounter an error while using `js2e` that does not mimic the above
Elm-like style, but instead looks like an Elixir stacktrace, please report this
as a bug by opening an issue and including a JSON schema example that recreates
the error.

## Contributing

If you feel like something is missing/wrong or if I've misinterpreted the JSON
schema spec, feel free to open an issue so we can discuss a solution.

Please consult `CONTRIBUTING.md` first before opening an issue.
