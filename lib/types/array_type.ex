defmodule JsonSchema.Types.ArrayType do
  @moduledoc """
  Represents a custom `array` type definition in a JSON schema.

  JSON Schema:

      "rectangles": {
        "type": "array",
        "items": {
          "$ref": "#/rectangle"
        }
      }

  Resulting in the Elixir representation:

      %ArrayType{name: "rectangles",
                 path: URI.parse("#/rectangles"),
                 items: URI.parse("#/rectangles/items")}
  """

  @type t :: %__MODULE__{
          name: String.t(),
          path: URI.t(),
          items: URI.t()
        }

  defstruct [:name, :path, :items]

  @spec new(String.t(), URI.t(), URI.t()) :: t
  def new(name, path, items) do
    %__MODULE__{name: name, path: path, items: items}
  end
end
