# Changelog

## v0.5.0 [2023-03-26]

### Added

- Now supports the `default` keyword for each schema node type.
- Now supports boolean values for the `additionalProperties` keyword.

### Changed

- When defining an anonymous type using the `items` keyword, it is now named
  `:anonymous` rather than `items` in the parsed document.

### Fixed

- Fixed a bug where the parser would throw an unexpected error if the `items`
  property contained a primitive type.

## v0.4.0 [2022-05-09]

### Changed

- Replaces auto-generated schema names like `zero` and `one` with `:anonymous`
  making it easier for a consuming project to decide what to do when a subschema
  does not have an explicit name. (#97)
- Replaces stringly-typed `type` properties for several schema types to instead
  use specific atoms corresponding to the set of valid JSON value type.
- Adds better error description for invalid `union` types.

## v0.3.0 [2019-10-30]

### Added

- Support for the generic `description` keyword (#14).
- support for the `const` keyword (#21).

### Fixed
- Various bugs related to parsing nested root object (#35).

## v0.2.0 [2019-03-24]

### Added

- Support for parsing the following JSON schema types:
  - `additionalProperties`, and
  - `patternProperties`.

### Changed

- Replaced the `TypePath` type wih the `URI` type when specifying local paths in
  a JSON schema document.

## v0.1.0 [2018-07-27]

> NOTE: This initial release is a fork of
> https://github.com/dragonwasrobot/json-schema-to-elm, and so this version
> contains all existing changes made in that project. As a result, the parser
> and inspection logic found in this first version reflects which parts of
> the JSON Schema specification was needed in the original project.

### Added

- Support for parsing the following JSON schema types:
  - `allOf`,
  - `anyOf`,
  - `array` (keyword `items` when value is a object),
  - `enum`,
  - `object`, (keyword `properties`),
  - `oneOf`,
  - `primitive` (keyword `type` except for `object` and `array`),
  - `tuple` (keyword `items` when value is a list of objects), and
  - `union` (keyword `type` when value is a list of strings).

- Parsing of the basic properties of a JSON schema document:
  - `schema`,
  - `$id`,
  - `$ref`,
  - `title`,
  - `description`,
  - `"definitions"`, and
  - `required`.

- Can resolve references, using `$ref`, across different JSON schema files as
  long as they are parsed together.

- Prints [human friendly error messages](http://elm-lang.org/blog/compiler-errors-for-humans).
