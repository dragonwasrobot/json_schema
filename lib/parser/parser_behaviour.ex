defmodule JsonSchema.Parser.ParserBehaviour do
  @moduledoc """
  Describes the functions needed to implement a parser for a JSON schema node.
  """

  alias JsonSchema.{Parser, Types}
  alias Parser.ParserResult

  @callback type?(Types.schemaNode()) :: boolean

  @callback parse(
              Types.schemaNode(),
              URI.t(),
              URI.t() | nil,
              URI.t(),
              String.t()
            ) :: ParserResult.t()
end
