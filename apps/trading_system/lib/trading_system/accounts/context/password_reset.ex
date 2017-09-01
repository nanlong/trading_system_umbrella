defmodule TradingSystem.Accounts.PasswordResetContext do
  alias TradingSystem.Accounts.PasswordReset

  def change(attrs \\ %{}) do
    %PasswordReset{}
    |> PasswordReset.changeset_email(attrs)
  end

  def create(attrs \\ %{}) do
    changeset = change(attrs)
    
    if changeset.valid? do
      {:ok, PasswordReset.get_user(changeset)}
    else
      {:error, %{changeset | action: :create}}
    end
  end
end