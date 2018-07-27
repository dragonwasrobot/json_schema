defmodule JsonSchema.Parser.ParserBehaviour do
  @moduledoc ~S"""
  Describes the functions needed to implement a parser for a JSON schema node.
  """

  alias JsonSchema.{Parser, TypePath, Types}
  alias Parser.ParserResult

  @callback type?(Types.schemaNode()) :: boolean

  @callback parse(
              Types.schemaNode(),
              URI.t(),
              URI.t() | nil,
              TypePath.t(),
              String.t()
            ) :: ParserResult.t()
end