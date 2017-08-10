defmodule TradingSystem.Web.SettingController do
  use TradingSystem.Web, :controller

  alias TradingSystem.Accounts

  plug Guardian.Plug.EnsureAuthenticated, 
    [handler: TradingSystem.Web.Guardian.ErrorHandler]
    when action in [:index, :show, :update]

  def index(conn, _params) do
    conn
    |> redirect(to: setting_path(conn, :show, "profile"))
  end

  def show(conn, %{"page" => "config"}) do
    config = 
      Accounts.get_config(user_id: conn.assigns.current_user.id)
      |> Map.update!(:account, &(:erlang.float_to_binary(&1, decimals: 2)))
    
    changeset = Accounts.change_config(config)

    conn
    |> assign(:changeset, changeset)
    |> render(:edit_config)
  end

  def show(conn, %{"page" => "profile"}) do
    changeset_profile = Accounts.change_user(:profile, conn.assigns.current_user)
    changeset_password = Accounts.change_user(:password, conn.assigns.current_user)

    conn
    |> assign(:changeset_profile, changeset_profile)
    |> assign(:changeset_password, changeset_password)
    |> render(:edit_profile)
  end

  def update(conn, %{"page" => "config", "config" => config_params}) do
    config = 
      Accounts.get_config(user_id: conn.assigns.current_user.id)
      |> Map.update!(:account, &(:erlang.float_to_binary(&1, decimals: 2)))

    case Accounts.update_config(config, config_params) do
      {:ok, _config} ->
        conn
        |> put_flash(:info, "修改成功.")
        |> redirect(to: setting_path(conn, :show, "config"))
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> assign(:changeset, changeset)
        |> render(:edit_config)
    end
  end

  def update(conn, %{"page" => "profile", "user" => user_params}) do
    user = conn.assigns.current_user

    case Accounts.update_user(:profile, user, user_params) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "修改成功.")
        |> redirect(to: setting_path(conn, :show, "profile"))
      {:error, %Ecto.Changeset{} = changeset} ->
        changeset_password = Accounts.change_user(:password, conn.assigns.current_user)

        conn
        |> assign(:changeset_profile, changeset)
        |> assign(:changeset_password, changeset_password)
        |> render(:edit_profile)
    end
  end

  def update(conn, %{"page" => "password", "user" => user_params}) do
    user = conn.assigns.current_user

    case Accounts.update_user(:password, user, user_params) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "修改成功.")
        |> redirect(to: setting_path(conn, :show, "profile"))
      {:error, %Ecto.Changeset{} = changeset} ->
        changeset_profile = Accounts.change_user(:profile, conn.assigns.current_user)

        conn
        |> assign(:changeset_profile, changeset_profile)
        |> assign(:changeset_password, changeset)
        |> render(:edit_profile)
    end
  end
end
