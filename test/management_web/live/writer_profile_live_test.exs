defmodule ManagementWeb.WriterProfileLiveTest do
  use ManagementWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Management.WriterManager

  @create_attrs %{first_name: "some first_name", full_name: "some full_name", gender: "some gender", last_name: "some last_name", profile_image: "some profile_image", sub_expiry_date: ~N[2010-04-17 14:00:00], sub_start_date: ~N[2010-04-17 14:00:00], suscription_type: "some suscription_type"}
  @update_attrs %{first_name: "some updated first_name", full_name: "some updated full_name", gender: "some updated gender", last_name: "some updated last_name", profile_image: "some updated profile_image", sub_expiry_date: ~N[2011-05-18 15:01:01], sub_start_date: ~N[2011-05-18 15:01:01], suscription_type: "some updated suscription_type"}
  @invalid_attrs %{first_name: nil, full_name: nil, gender: nil, last_name: nil, profile_image: nil, sub_expiry_date: nil, sub_start_date: nil, suscription_type: nil}

  defp fixture(:writer_profile) do
    {:ok, writer_profile} = WriterManager.create_writer_profile(@create_attrs)
    writer_profile
  end

  defp create_writer_profile(_) do
    writer_profile = fixture(:writer_profile)
    %{writer_profile: writer_profile}
  end

  describe "Index" do
    setup [:create_writer_profile]

    test "lists all writer_profiles", %{conn: conn, writer_profile: writer_profile} do
      {:ok, _index_live, html} = live(conn, Routes.writer_profile_index_path(conn, :index))

      assert html =~ "Listing Writer profiles"
      assert html =~ writer_profile.first_name
    end

    test "saves new writer_profile", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.writer_profile_index_path(conn, :index))

      assert index_live |> element("a", "New Writer profile") |> render_click() =~
               "New Writer profile"

      assert_patch(index_live, Routes.writer_profile_index_path(conn, :new))

      assert index_live
             |> form("#writer_profile-form", writer_profile: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#writer_profile-form", writer_profile: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.writer_profile_index_path(conn, :index))

      assert html =~ "Writer profile created successfully"
      assert html =~ "some first_name"
    end

    test "updates writer_profile in listing", %{conn: conn, writer_profile: writer_profile} do
      {:ok, index_live, _html} = live(conn, Routes.writer_profile_index_path(conn, :index))

      assert index_live |> element("#writer_profile-#{writer_profile.id} a", "Edit") |> render_click() =~
               "Edit Writer profile"

      assert_patch(index_live, Routes.writer_profile_index_path(conn, :edit, writer_profile))

      assert index_live
             |> form("#writer_profile-form", writer_profile: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#writer_profile-form", writer_profile: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.writer_profile_index_path(conn, :index))

      assert html =~ "Writer profile updated successfully"
      assert html =~ "some updated first_name"
    end

    test "deletes writer_profile in listing", %{conn: conn, writer_profile: writer_profile} do
      {:ok, index_live, _html} = live(conn, Routes.writer_profile_index_path(conn, :index))

      assert index_live |> element("#writer_profile-#{writer_profile.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#writer_profile-#{writer_profile.id}")
    end
  end

  describe "Show" do
    setup [:create_writer_profile]

    test "displays writer_profile", %{conn: conn, writer_profile: writer_profile} do
      {:ok, _show_live, html} = live(conn, Routes.writer_profile_show_path(conn, :show, writer_profile))

      assert html =~ "Show Writer profile"
      assert html =~ writer_profile.first_name
    end

    test "updates writer_profile within modal", %{conn: conn, writer_profile: writer_profile} do
      {:ok, show_live, _html} = live(conn, Routes.writer_profile_show_path(conn, :show, writer_profile))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Writer profile"

      assert_patch(show_live, Routes.writer_profile_show_path(conn, :edit, writer_profile))

      assert show_live
             |> form("#writer_profile-form", writer_profile: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#writer_profile-form", writer_profile: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.writer_profile_show_path(conn, :show, writer_profile))

      assert html =~ "Writer profile updated successfully"
      assert html =~ "some updated first_name"
    end
  end
end
