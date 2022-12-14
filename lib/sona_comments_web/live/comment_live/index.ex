defmodule SonaCommentsWeb.CommentLive.Index do
  use SonaCommentsWeb, :live_view

  alias SonaComments.Comments.Comment
  alias SonaComments.Comments
  alias SonaComments.Comments.Comment

  alias SonaCommentsWeb.CommentLive.CommentThreadComponent

  @impl true
  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        comments: Comments.list_top_level_comments(),
        changeset: Comments.change_comment()
      )

    {:ok, socket, temporary_assigns: [comments: []]}
  end

  @impl true
  def handle_event("save-comment", %{"comment" => comment_params}, socket) do
    case Comments.create_comment(comment_params) do
      {:ok, comment} ->
        {:noreply,
         assign(socket,
           comments: Comments.list_top_level_comments(),
           changeset: Comments.change_comment()
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> assign(changeset: changeset)
         |> put_flash(:error, "We could not post your comment right now, please try again!")}
    end
  end

  @impl true
  def handle_event("validate", %{"comment" => comment_params}, socket) do
    changeset =
      %Comment{}
      |> Comments.change_comment(comment_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    comment = Comments.get_comment!(id)
    {:ok, _} = Comments.delete_comment(comment)

    {:noreply, assign(socket, :comments, Comments.list_comments())}
  end
end
