defmodule SonaCommentsWeb.Integration.CommentLiveTest do
  use SonaCommentsWeb.ConnCase

  import Phoenix.LiveViewTest
  import SonaComments.CommentsFixtures
  import SonaComments.Support.TimeHelper

  @create_attrs %{body: "a new comment"}
  @reply_attrs %{body: "a new reply"}
  @invalid_attrs %{body: nil}

  defp create_comment(_) do
    top_comment = comment_fixture()

    %{
      comments: [
        top_comment,
        comment_fixture(body: "A reply", parent_id: top_comment.id),
        comment_fixture(body: "Another reply", parent_id: top_comment.id)
      ]
    }
  end

  describe "Index" do
    setup [:create_comment]

    test "lists all comments", %{conn: conn, comments: comments} do
      {:ok, _view, html} = live(conn, Routes.comment_index_path(conn, :index))

      for comment <- comments do
        assert html =~ comment.body
      end
    end

    test "saves a new comment", %{conn: conn} do
      {:ok, view, _html} = live(conn, Routes.comment_index_path(conn, :index))

      assert view
             |> form("#comment-form", comment: @invalid_attrs)
             |> render_change() =~ "You cannot post an empty comment"

      result =
        view
        |> form("#comment-form", comment: @create_attrs)
        |> render_submit()

      assert result =~ @create_attrs.body
    end

    test "displays broadcast comments", %{conn: conn} do
      {:ok, view, _html} = live(conn, Routes.comment_index_path(conn, :index))

      new_comment = comment_fixture(body: "broadcast comment")

      send(view.pid, {:new_comment, new_comment})

      wait_until(fn ->
        assert render(view) =~ "broadcast comment"
      end)
    end
  end

  describe "CommentThreadComponent" do
    setup [:create_comment]

    test "replies to a comment", %{conn: conn, comments: comments} do
      {:ok, view, _html} = live(conn, Routes.comment_index_path(conn, :index))

      comment_id = Enum.at(comments, 0).id

      view
      |> element("#comment-#{comment_id} #reply-to-comment-#{comment_id}", "Reply")
      |> render_click()

      result =
        view
        |> form("#comment-#{comment_id} form", comment: @reply_attrs)
        |> render_submit()

      assert result =~ @reply_attrs.body
    end
  end
end
