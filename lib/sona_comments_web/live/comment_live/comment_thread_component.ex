defmodule SonaCommentsWeb.CommentLive.CommentThreadComponent do
  use SonaCommentsWeb, :live_component

  alias SonaComments.Comments

  # batches download of each thread, avoid the N+1 query problem
  # https://hexdocs.pm/phoenix_live_view/Phoenix.LiveComponent.html#module-preloading-and-update
  def preload(list_of_assigns) do
    parent_ids = Enum.map(list_of_assigns, & &1.id)
    replies_by_parent_id = Comments.get_replies(parent_ids)
    Enum.map(list_of_assigns, &Map.put(&1, :children, Map.get(replies_by_parent_id, &1.id, [])))
  end

  def mount(socket) do
    {:ok,
     assign(socket,
       form_visible: false,
       changeset: Comments.change_comment()
     ), temporary_assigns: [comment: nil, children: []]}
  end

  def render(assigns) do
    ~H"""
    <li id={@id}><%= @comment.body %></li>
    """
  end
end
