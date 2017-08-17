defmodule TradingSystem.Web.Email do
  import Bamboo.Email

  @from "趋势跟踪系统<support@mg.trendfollowing.cc>"

  def welcome_email do
    new_email()
    |> to("200006506@qq.com")
    |> from(@from)
    |> subject("Welcome!!!")
    |> html_body("<strong>Welcome</strong>")
    |> text_body("welcome")
  end
end