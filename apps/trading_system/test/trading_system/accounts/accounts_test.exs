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
end
