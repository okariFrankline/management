defmodule ManagementWeb.AccountLiveTest do
  use ManagementWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Management.AccountManager

  @create_attrs %{account_role: "some account_role", account_type: "some account_type", confirmed_at: "2010-04-17T14:00:00Z", email: "some email", is_active: true, is_suspended: true, password_hash: "some password_hash", subscription_end_date: "2010-04-17T14:00:00Z", subscription_start_date: "2010-04-17T14:00:00Z"}
  @update_attrs %{account_role: "some updated account_role", account_type: "some updated account_type", confirmed_at: "2011-05-18T15:01:01Z", email: "some updated email", is_active: false, is_suspended: false, password_hash: "some updated password_hash", subscription_end_date: "2011-05-18T15:01:01Z", subscription_start_date: "2011-05-18T15:01:01Z"}
  @invalid_attrs %{account_role: nil, account_type: nil, confirmed_at: nil, email: nil, is_active: nil, is_suspended: nil, password_hash: nil, subscription_end_date: nil, subscription_start_date: nil}

  defp fixture(:account) do
    {:ok, account} = AccountManager.create_account(@create_attrs)
    account
  end

  defp create_account(_) do
    account = fixture(:account)
    %{account: account}
  end

  describe "Index" do
    setup [:create_account]

    test "lists all accounts", %{conn: conn, account: account} do
      {:ok, _index_live, html} = live(conn, Routes.account_index_path(conn, :index))

      assert html =~ "Listing Accounts"
      assert html =~ account.account_role
    end

    test "saves new account", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.account_index_path(conn, :index))

      assert index_live |> element("a", "New Account") |> render_click() =~
               "New Account"

      assert_patch(index_live, Routes.account_index_path(conn, :new))

      assert index_live
             |> form("#account-form", account: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#account-form", account: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.account_index_path(conn, :index))

      assert html =~ "Account created successfully"
      assert html =~ "some account_role"
    end

    test "updates account in listing", %{conn: conn, account: account} do
      {:ok, index_live, _html} = live(conn, Routes.account_index_path(conn, :index))

      assert index_live |> element("#account-#{account.id} a", "Edit") |> render_click() =~
               "Edit Account"

      assert_patch(index_live, Routes.account_index_path(conn, :edit, account))

      assert index_live
             |> form("#account-form", account: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#account-form", account: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.account_index_path(conn, :index))

      assert html =~ "Account updated successfully"
      assert html =~ "some updated account_role"
    end

    test "deletes account in listing", %{conn: conn, account: account} do
      {:ok, index_live, _html} = live(conn, Routes.account_index_path(conn, :index))

      assert index_live |> element("#account-#{account.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#account-#{account.id}")
    end
  end

  describe "Show" do
    setup [:create_account]

    test "displays account", %{conn: conn, account: account} do
      {:ok, _show_live, html} = live(conn, Routes.account_show_path(conn, :show, account))

      assert html =~ "Show Account"
      assert html =~ account.account_role
    end

    test "updates account within modal", %{conn: conn, account: account} do
      {:ok, show_live, _html} = live(conn, Routes.account_show_path(conn, :show, account))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Account"

      assert_patch(show_live, Routes.account_show_path(conn, :edit, account))

      assert show_live
             |> form("#account-form", account: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#account-form", account: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.account_show_path(conn, :show, account))

      assert html =~ "Account updated successfully"
      assert html =~ "some updated account_role"
    end
  end
end
