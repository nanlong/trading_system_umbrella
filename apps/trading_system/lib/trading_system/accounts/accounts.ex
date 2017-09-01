defmodule TradingSystem.Accounts do

  # user
  alias TradingSystem.Accounts.UserContext

  defdelegate vip?(user), to: UserContext
  defdelegate get_user(params), to: UserContext, as: :get
  defdelegate get_user!(params), to: UserContext, as: :get!
  defdelegate create_user(attrs), to: UserContext, as: :create
  defdelegate update_user(prefix, user, attrs), to: UserContext, as: :update
  defdelegate change_user(user), to: UserContext, as: :change
  defdelegate change_user(prefix, user), to: UserContext, as: :change

  # config
  alias TradingSystem.Accounts.ConfigContext

  defdelegate get_config(params), to: ConfigContext, as: :get
  defdelegate get_config!(params), to: ConfigContext, as: :get!
  defdelegate update_config(config, attrs), to: ConfigContext, as: :update
  defdelegate change_config(config), to: ConfigContext, as: :change

  # session
  alias TradingSystem.Accounts.SessionContext

  defdelegate change_session(session), to: SessionContext, as: :change
  defdelegate create_session(attrs), to: SessionContext, as: :create
  defdelegate sign_token(user), to: SessionContext
  defdelegate verify_token(token), to: SessionContext
  
  # password reset
  alias TradingSystem.Accounts.PasswordResetContext

  defdelegate change_password_reset, to: PasswordResetContext, as: :change
  defdelegate change_password_reset(attrs), to: PasswordResetContext, as: :change
  defdelegate create_password_reset(attrs), to: PasswordResetContext, as: :create
end
