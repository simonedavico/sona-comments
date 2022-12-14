defmodule SonaCommentsWeb.CommentLive.Index do
  use SonaCommentsWeb, :live_view

  alias SonaComments.Comments.Comment
  alias SonaComments.Comments
  alias SonaComments.Comments.Comment

  alias SonaCommentsWeb.CommentLive.CommentThreadComponent

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Comments.subscribe()

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
           comments: [comment],
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
  def handle_info({:new_comment, comment}, socket) do
    if is_reply?(comment) do
      send_update(CommentThreadComponent, id: comment.parent_id, replies: [comment])
      {:noreply, socket}
    else
      {:noreply, assign(socket, comments: [comment])}
    end
  end

  defp is_reply?(%Comment{parent_id: nil}), do: false
  defp is_reply?(%Comment{parent_id: _}), do: true
end
