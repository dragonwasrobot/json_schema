defmodule JsonSchema.Parser.ParserError do
  @moduledoc """
  Represents an error generated while parsing a JSON schema object.
  """

  use TypedStruct
  alias JsonSchema.Types

  @type error_type ::
          :could_not_read_file
          | :invalid_json
          | :unresolved_reference
          | :unknown_type
          | :unexpected_type
          | :unexpected_value
          | :unknown_enum_type
          | :unknown_union_type
          | :unknown_primitive_type
          | :unknown_node_type

  typedstruct do
    field :identifier, Types.typeIdentifier(), enforce: true
    field :error_type, error_type, enforce: true
    field :message, String.t(), enforce: true
  end

  @doc """
  Constructs a `ParserError`.
  """
  @spec new(Types.typeIdentifier(), atom, String.t()) :: t
  def new(identifier, error_type, message) do
    %__MODULE__{
      identifier: identifier,
      error_type: error_type,
      message: message
    }
  end
end

defmodule JsonSchema.Parser.ParserWarning do
  @moduledoc """
  Represents a warning generated while parsing a JSON schema object.
  """

  use TypedStruct
  alias JsonSchema.Types

  @type warning_type :: atom

  typedstruct do
    field :identifier, Types.typeIdentifier(), enforce: true
    field :warning_type, warning_type, enforce: true
    field :message, String.t(), enforce: true
  end

  @doc """
  Constructs a `ParserWarning`.
  """
  @spec new(Types.typeIdentifier(), atom, String.t()) :: t
  def new(identifier, warning_type, message) do
    %__MODULE__{
      identifier: identifier,
      warning_type: warning_type,
      message: message
    }
  end
end

defmodule JsonSchema.Parser.ParserResult do
  @moduledoc """
  Represents the result of parsing a subset of a JSON schema including
  parsed types, warnings, and errors.
  """

  use TypedStruct
  require Logger
  alias JsonSchema.{Parser, Types}
  alias Parser.{ErrorUtil, ParserError, ParserWarning}

  typedstruct do
    field :type_dict, Types.typeDictionary(), enforce: true
    field :warnings, [ParserWarning.t()], enforce: true
    field :errors, [ParserError.t()], enforce: true
  end

  @doc """
  Returns an empty `ParserResult`.
  """
  @spec new :: t
  def new, do: %__MODULE__{type_dict: %{}, warnings: [], errors: []}

  @doc """
  Creates a `ParserResult` from a type dictionary.

  A `ParserResult` consists of a type dictionary corresponding to the
  succesfully parsed part of a JSON schema object, and a list of warnings and
  errors encountered while parsing.
  """
  @spec new(Types.typeDictionary(), [ParserWarning.t()], [ParserError.t()]) :: t
  def new(type_dict, warnings \\ [], errors \\ []) do
    %__MODULE__{type_dict: type_dict, warnings: warnings, errors: errors}
  end

  @doc """
  Merges two `ParserResult`s and adds any collisions errors from merging their
  type dictionaries to the list of errors in the merged `ParserResult`.
  """
  @spec merge(t, t) :: t
  def merge(
        %__MODULE__{
          type_dict: type_dict1,
          warnings: warnings1,
          errors: errors1
        },
        %__MODULE__{
          type_dict: type_dict2,
          warnings: warnings2,
          errors: errors2
        }
      ) do
    keys1 = type_dict1 |> Map.keys() |> MapSet.new()
    keys2 = type_dict2 |> Map.keys() |> MapSet.new()

    collisions =
      keys1
      |> MapSet.intersection(keys2)
      |> Enum.map(fn schema_path ->
        {schema_path, [ErrorUtil.name_collision(schema_path)]}
      end)

    merged_type_dict = type_dict1 |> Map.merge(type_dict2)
    merged_warnings = warnings1 |> Enum.concat(warnings2)
    merged_errors = collisions |> Enum.concat(errors1) |> Enum.concat(errors2)

    %__MODULE__{
      type_dict: merged_type_dict,
      warnings: merged_warnings,
      errors: merged_errors
    }
  end
end

defmodule JsonSchema.Parser.SchemaResult do
  @moduledoc """
  Represents the result of parsing a whole JSON schema including the parsed
  schema, along with all warnings and errors generated while parsing the schema
  and its members.
  """

  use TypedStruct
  require Logger
  alias JsonSchema.Parser.{ErrorUtil, ParserError, ParserWarning}
  alias JsonSchema.Types

  typedstruct do
    field :schema_dict, Types.schemaDictionary(), enforce: true
    field :warnings, [{Path.t(), [ParserWarning.t()]}], enforce: true
    field :errors, [{Path.t(), [ParserError.t()]}], enforce: true
  end

  @doc """
  Returns an empty `SchemaResult`.
  """
  @spec new :: t
  def new, do: %__MODULE__{schema_dict: %{}, warnings: [], errors: []}

  @doc """
  Constructs a new `SchemaResult`. A `SchemaResult` consists of a schema
  dictionary corresponding to the succesfully parsed JSON schema files,
  and a list of warnings and errors encountered while parsing.
  """
  @spec new(Types.schemaDictionary(), [{Path.t(), [ParserWarning.t()]}], [
          {Path.t(), [ParserError.t()]}
        ]) :: t
  def new(schema_dict, warnings \\ [], errors \\ []) do
    %__MODULE__{schema_dict: schema_dict, warnings: warnings, errors: errors}
  end

  @doc """
  Merges two `SchemaResult`s and adds any collisions errors from merging their
  schema dictionaries to the list of errors in the merged `SchemaResult`.
  """
  @spec merge(t, t) :: t
  def merge(
        %__MODULE__{
          schema_dict: schema_dict1,
          warnings: warnings1,
          errors: errors1
        },
        %__MODULE__{
          schema_dict: schema_dict2,
          warnings: warnings2,
          errors: errors2
        }
      ) do
    keys1 = schema_dict1 |> Map.keys() |> MapSet.new()
    keys2 = schema_dict2 |> Map.keys() |> MapSet.new()

    collisions =
      keys1
      |> MapSet.intersection(keys2)
      |> Enum.map(fn schema_path ->
        {schema_path, [ErrorUtil.name_collision(schema_path)]}
      end)

    merged_schema_dict = Map.merge(schema_dict1, schema_dict2)
    merged_warnings = Enum.uniq(warnings1 ++ warnings2)
    merged_errors = Enum.uniq(collisions ++ errors1 ++ errors2)

    %__MODULE__{
      schema_dict: merged_schema_dict,
      warnings: merged_warnings,
      errors: merged_errors
    }
  end
end
