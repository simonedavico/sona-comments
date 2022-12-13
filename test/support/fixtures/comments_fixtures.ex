defmodule SonaComments.CommentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SonaComments.Comments` context.
  """

  @doc """
  Generate a comment.
  """
  def comment_fixture(attrs \\ %{}) do
    {:ok, comment} =
      attrs
      |> Enum.into(%{
        body: "some body"
      })
      |> SonaComments.Comments.create_comment()

    comment
  end
end
