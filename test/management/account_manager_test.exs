defmodule Management.AccountManagerTest do
  use Management.DataCase

  alias Management.AccountManager

  describe "accounts" do
    alias Management.AccountManager.Account

    @valid_attrs %{account_role: "some account_role", account_type: "some account_type", confirmed_at: "2010-04-17T14:00:00Z", email: "some email", is_active: true, is_suspended: true, password_hash: "some password_hash", subscription_end_date: "2010-04-17T14:00:00Z", subscription_start_date: "2010-04-17T14:00:00Z"}
    @update_attrs %{account_role: "some updated account_role", account_type: "some updated account_type", confirmed_at: "2011-05-18T15:01:01Z", email: "some updated email", is_active: false, is_suspended: false, password_hash: "some updated password_hash", subscription_end_date: "2011-05-18T15:01:01Z", subscription_start_date: "2011-05-18T15:01:01Z"}
    @invalid_attrs %{account_role: nil, account_type: nil, confirmed_at: nil, email: nil, is_active: nil, is_suspended: nil, password_hash: nil, subscription_end_date: nil, subscription_start_date: nil}

    def account_fixture(attrs \\ %{}) do
      {:ok, account} =
        attrs
        |> Enum.into(@valid_attrs)
        |> AccountManager.create_account()

      account
    end

    test "list_accounts/0 returns all accounts" do
      account = account_fixture()
      assert AccountManager.list_accounts() == [account]
    end

    test "get_account!/1 returns the account with given id" do
      account = account_fixture()
      assert AccountManager.get_account!(account.id) == account
    end

    test "create_account/1 with valid data creates a account" do
      assert {:ok, %Account{} = account} = AccountManager.create_account(@valid_attrs)
      assert account.account_role == "some account_role"
      assert account.account_type == "some account_type"
      assert account.confirmed_at == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert account.email == "some email"
      assert account.is_active == true
      assert account.is_suspended == true
      assert account.password_hash == "some password_hash"
      assert account.subscription_end_date == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert account.subscription_start_date == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
    end

    test "create_account/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = AccountManager.create_account(@invalid_attrs)
    end

    test "update_account/2 with valid data updates the account" do
      account = account_fixture()
      assert {:ok, %Account{} = account} = AccountManager.update_account(account, @update_attrs)
      assert account.account_role == "some updated account_role"
      assert account.account_type == "some updated account_type"
      assert account.confirmed_at == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert account.email == "some updated email"
      assert account.is_active == false
      assert account.is_suspended == false
      assert account.password_hash == "some updated password_hash"
      assert account.subscription_end_date == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert account.subscription_start_date == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
    end

    test "update_account/2 with invalid data returns error changeset" do
      account = account_fixture()
      assert {:error, %Ecto.Changeset{}} = AccountManager.update_account(account, @invalid_attrs)
      assert account == AccountManager.get_account!(account.id)
    end

    test "delete_account/1 deletes the account" do
      account = account_fixture()
      assert {:ok, %Account{}} = AccountManager.delete_account(account)
      assert_raise Ecto.NoResultsError, fn -> AccountManager.get_account!(account.id) end
    end

    test "change_account/1 returns a account changeset" do
      account = account_fixture()
      assert %Ecto.Changeset{} = AccountManager.change_account(account)
    end
  end
end
