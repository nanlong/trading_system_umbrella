defmodule TradingSystem.Accounts.SessionContext do
  alias TradingSystem.Accounts.Session
  alias TradingSystem.Accounts.UserContext
  alias Phoenix.Token
  alias TradingSystem.Web.Endpoint

  def create(attrs \\ %{}) do
    changeset = Session.changeset(%Session{}, attrs)
    
    if changeset.valid? do
      {:ok, Session.get_user(changeset)}
    else
      {:error, %{changeset | action: :create}}
    end
  end

  def change(%Session{} = session) do
    Session.changeset(session, %{})
  end

  def sign_token(user, token_name \\ "user_id") do
    Token.sign(Endpoint, token_name, user.id)
  end

  def verify_token(token, token_name \\ "user_id", max_age \\ 60 * 60 * 12 * 30) do
    case Token.verify(Endpoint, token_name, token, max_age: max_age) do
      {:ok, user_id} -> 
        case UserContext.get(user_id) do
          nil -> {:error, "invalid authorization token"}
          user -> {:ok, user}
        end
      {:error, _} -> {:error, "invalid authorization token"}
    end
  end
end