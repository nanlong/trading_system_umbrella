defmodule TradingSystem.AccountsTest do
  use TradingSystem.DataCase

  alias TradingSystem.Accounts
  alias TradingSystem.Accounts.User

  @user_attrs %{email: "test@qushi.pro", password: "123456", password_confirmation: "123456"}

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(@user_attrs)
      |> Accounts.create_user()
      
    user
    |> Map.put(:password, nil)
    |> Map.put(:password_confirmation, nil)
  end

  def create_user(_attrs \\ %{}) do
    user = user_fixture()
    {:ok, user: user}
  end

  describe "users" do
    @valid_attrs %{email: "test@qushi.pro", password: "123456", password_confirmation: "123456"}
    @invalid_attrs %{email: nil, password: nil, password_confirmation: nil}

    test "list_users/0 returns all users" do
      user_fixture()
      assert Accounts.list_users()
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id)
      assert Accounts.get_config(user_id: user.id)
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.email == "test@qushi.pro"
      assert user.nickname == "test"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end


  describe "session" do
    alias TradingSystem.Accounts.User

    @valid_attrs %{email: "test@qushi.pro", password: "123456"}
    @invalid_attrs %{email: nil, password: nil}

    test "create_session/1 with valid data creates a session" do
      user_fixture()
      assert {:ok, %User{}} = Accounts.create_session(@valid_attrs)
    end

    test "create_session/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_session(@invalid_attrs)
    end
  end

  describe "configs" do
    setup [:create_user]

    alias TradingSystem.Accounts.Config

    @valid_attrs %{atr_account_ratio: 120.5, atr_add_step: 120.5, atr_days: 42, atr_stop_step: 120.5, close_days: 42, create_days: 42}
    @update_attrs %{atr_account_ratio: 456.7, atr_add_step: 456.7, atr_days: 43, atr_stop_step: 456.7, close_days: 43, create_days: 43}
    @invalid_attrs %{atr_account_ratio: nil, atr_add_step: nil, atr_days: nil, atr_stop_step: nil, close_days: nil, create_days: nil}

    def config_fixture(user, attrs \\ %{}) do
      {:ok, config} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Map.put_new(:user_id, user.id)
        |> Accounts.create_config()

      config
    end

    test "list_configs/0 returns all configs", %{user: user} do
      config = config_fixture(user)
      assert Accounts.list_configs() == [config]
    end

    test "get_config!/1 returns the config with given id", %{user: user} do
      config = config_fixture(user)
      assert Accounts.get_config!(config.id) == config
    end

    test "create_config/1 with valid data creates a config", %{user: user} do
      assert {:ok, %Config{} = config} = Accounts.create_config(Map.put(@valid_attrs, :user_id, user.id))
      assert config.atr_account_ratio == 120.5
      assert config.atr_add_step == 120.5
      assert config.atr_days == 42
      assert config.atr_stop_step == 120.5
      assert config.close_days == 42
      assert config.create_days == 42
    end

    test "create_config/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_config(@invalid_attrs)
    end

    test "update_config/2 with valid data updates the config", %{user: user} do
      config = config_fixture(user)
      assert {:ok, config} = Accounts.update_config(config, @update_attrs)
      assert %Config{} = config
      assert config.atr_account_ratio == 456.7
      assert config.atr_add_step == 456.7
      assert config.atr_days == 43
      assert config.atr_stop_step == 456.7
      assert config.close_days == 43
      assert config.create_days == 43
    end

    test "delete_config/1 deletes the config", %{user: user} do
      config = config_fixture(user)
      assert {:ok, %Config{}} = Accounts.delete_config(config)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_config!(config.id) end
    end

    test "change_config/1 returns a config changeset", %{user: user} do
      config = config_fixture(user)
      assert %Ecto.Changeset{} = Accounts.change_config(config)
    end
  end
end
