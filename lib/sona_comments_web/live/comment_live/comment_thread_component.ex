defmodule SonaCommentsWeb.CommentLive.CommentThreadComponent do
  use SonaCommentsWeb, :live_component

  alias SonaComments.Comments

  # batches download of each thread, avoid the N+1 query problem
  # https://hexdocs.pm/phoenix_live_view/Phoenix.LiveComponent.html#module-preloading-and-update
  def preload(list_of_assigns) do
    parent_ids = Enum.map(list_of_assigns, & &1.id)
    replies_by_parent_id = Comments.get_replies(parent_ids)
    Enum.map(list_of_assigns, &Map.put(&1, :replies, Map.get(replies_by_parent_id, &1.id, [])))
  end

  def mount(socket) do
    {:ok,
     assign(socket,
       changeset: Comments.change_comment(),
       show_reply_form: false
     ), temporary_assigns: [comment: nil, replies: []]}
  end

  def render(assigns) do
    ~H"""
    <article id={"comment-#{@id}"}>
      <%= @comment.body %>

      <%= if @show_reply_form do %>
        <.form :let={f} for={@changeset} phx-submit="save-reply" phx-target={@myself}>
          <%= textarea f,
            :body,
            rows: 2,
            required: true,
            autofocus: true,
            placeholder: "Your reply...",
            oninvalid: "this.setCustomValidity('You cannot post an empty comment!')",
            oninput: "this.setCustomValidity('')"
          %>
          <button phx-click="toggle-reply-form" phx-target={@myself}>Cancel</button>
          <button type="submit">Reply</button>
        </.form>
      <% else %>
        <button phx-click="toggle-reply-form" phx-target={@myself}>Reply</button>
      <% end %>

      <section class="comment-replies" phx-update="append" id={"replies-#{@id}"}>
        <%= for reply <- @replies do %>
          <.live_component module={__MODULE__} id={reply.id} comment={reply} />
        <% end %>
      </section>
    </article>
    """
  end

  def handle_event("toggle-reply-form", _, socket) do
    {:noreply, update(socket, :show_reply_form, &(!&1))}
  end

  def handle_event("save-reply", %{"comment" => comment_params}, socket) do
    comment_params
    |> Map.put("parent_id", socket.assigns.id)
    |> Comments.create_comment()
    |> case do
      {:ok, new_comment} ->
        {:noreply, assign(socket, show_reply_form: false, replies: [new_comment])}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> assign(changeset: changeset)
         |> put_flash(:error, "We could not post your comment right now, please try again!")}
    end
  end
end
