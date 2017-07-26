defmodule TradingSystem.Graphql.ErrorHelpers do

  def format_changeset(changeset) do
    changeset.errors
    |> Enum.map(fn({key, {message, context}}) -> 
      [
        message: "#{key} #{message}",
        field: key,
        reason: message,
        details: context
      ]
    end)
  end
end