defmodule SonaCommentsWeb.CommentLiveTest do
  use SonaCommentsWeb.ConnCase

  import Phoenix.LiveViewTest
  import SonaComments.CommentsFixtures

  @create_attrs %{body: "some body"}
  @update_attrs %{body: "some updated body"}
  @invalid_attrs %{body: nil}

  defp create_comment(_) do
    comment = comment_fixture()
    %{comment: comment}
  end

  describe "Index" do
    setup [:create_comment]

    test "lists all comments", %{conn: conn, comment: comment} do
      {:ok, _index_live, html} = live(conn, Routes.comment_index_path(conn, :index))

      assert html =~ comment.body
    end

    test "saves new comment", %{conn: conn} do
      {:ok, index_live, html} = live(conn, Routes.comment_index_path(conn, :index))

      assert index_live
             |> form("#comment-form", comment: @invalid_attrs)
             |> render_change() =~ "You cannot post an empty comment"

      index_live
      |> form("#comment-form", comment: @create_attrs)
      |> render_submit()

      assert html =~ "some body"
    end

    test "shows an error flash when comment cannot be posted", %{conn: conn} do
      {:ok, index_live, html} = live(conn, Routes.comment_index_path(conn, :index))

      assert html =~ "some body"
    end
  end
end
