defmodule TradingSystem.Web.Email do
  use Bamboo.Phoenix, view: TradingSystem.Web.EmailView

  alias TradingSystem.Accounts
  alias TradingSystem.Accounts.User
  alias TradingSystem.Web.Mailer

  @from "趋势跟踪系统<support@mg.trendfollowing.cc>"

  @doc """
  欢迎邮件
  """
  def welcome(address) do
    base_email()
    |> to(address)
    |> subject("欢迎注册")
    |> render(:welcome)
    |> Mailer.deliver_later()
  end

  @doc """
  找回密码邮件
  """
  def password_reset(%User{} = user) do 
    base_email()
    |> to(user.email)
    |> subject("找回您的账号密码")
    |> assign(:user, user)
    |> assign(:token, Accounts.sign_token(user))
    |> render(:password_reset)
    |> Mailer.deliver_later()
  end

  defp base_email do
    new_email()
    |> from(@from)
    |> put_html_layout({TradingSystem.Web.LayoutView, "email.html"})
  end
end