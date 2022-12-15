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
    <article id={"comment-#{@id}"} class="w-full">
      <section class="comment-box flex flex-col" tabindex="0">
        <span
          class="w-full block px-4 py-2 bg-white border border-gray-200 rounded-lg shadow-md hover:bg-gray-100 dark:bg-gray-800 dark:border-gray-700 dark:hover:bg-gray-700"
        >
          <span class="prose prose-slate dark:prose-invert">
          <%= @comment.body %>
          </span>
        </span>

        <%= if @show_reply_form do %>
          <.form :let={f} for={@changeset} phx-submit="save-reply" phx-target={@myself}>
            <%= textarea f,
              :body,
              class: "block p-2.5 w-full text-sm text-gray-900 bg-gray-50 rounded-lg border border-gray-300 focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500 mt-4",
              rows: 2,
              required: true,
              phx_hook: "autofocus",
              placeholder: "Your reply...",
              oninvalid: "this.setCustomValidity('You cannot post an empty comment!')",
              oninput: "this.setCustomValidity('')"
            %>
            <div class="flex justify-end">
              <button
                phx-click="toggle-reply-form"
                phx-target={@myself}
                class="text-white bg-gradient-to-br from-pink-500 to-orange-400 hover:bg-gradient-to-bl focus:ring-4 focus:outline-none focus:ring-pink-200 dark:focus:ring-pink-800 font-medium rounded-lg text-sm px-5 py-2.5 text-center mr-2 my-2"
              >
                Cancel
              </button>
              <button
                class="text-white bg-gradient-to-r from-blue-500 via-blue-600 to-blue-700 hover:bg-gradient-to-br focus:ring-4 focus:outline-none focus:ring-blue-300 dark:focus:ring-blue-800 shadow-lg shadow-blue-500/50 dark:shadow-lg dark:shadow-blue-800/80 font-medium rounded-lg text-sm px-5 py-2.5 text-center mr-2 my-2"
                type="submit"
              >
                Reply
              </button>
            </div>
          </.form>
        <% else %>
          <button
            id={"reply-to-comment-#{@id}"}
            phx-click="toggle-reply-form"
            phx-target={@myself}
            class="toggle-reply-form self-end mr-4 py-1 font-medium text-slate-600 dark:text-slate-500 hover:underline"
          >
            Reply
          </button>
        <% end %>
      </section>

      <section class="pl-8" class="comment-replies" phx-update="prepend" id={"replies-#{@id}"}>
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
