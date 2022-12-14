defmodule SonaCommentsWeb.CommentThreadComponentTest do
  use SonaCommentsWeb.ConnCase

  import Phoenix.LiveViewTest
  import SonaComments.CommentsFixtures

  alias SonaCommentsWeb.CommentLive.CommentThreadComponent

  # this test is limited, interactions have to be tested through a LiveView
  # UPDATE: this could probably be done with live_isolated
  describe "CommentThreadComponent" do

    test "renders the comment" do
      comment = comment_fixture()

      assert render_component(CommentThreadComponent, id: 123, comment: comment) =~
               "some body"
    end
  end
end
