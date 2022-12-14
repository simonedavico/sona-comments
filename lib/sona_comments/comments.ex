defmodule SonaComments.Comments do
  @moduledoc """
  The Comments context.
  """

  import Ecto.Query, warn: false
  alias SonaComments.Repo

  alias SonaComments.Comments.Comment

  @topic inspect(__MODULE__)

  def subscribe do
    Phoenix.PubSub.subscribe(SonaComments.PubSub, @topic)
  end

  @doc """
  Returns the list of comments.

  ## Examples

      iex> list_comments()
      [%Comment{}, ...]

  """
  def list_comments do
    Repo.all(Comment)
  end

  @doc """
  Returns the list of top-level comments (i.e. not replies).

  ## Examples

      iex> list_top_level_comments()
      [%Comment{}, ...]

  """
  def list_top_level_comments do
    from(c in Comment, where: is_nil(c.parent_id), order_by: [asc: :inserted_at])
    |> Repo.all()
  end

  @doc """
  Gets a single comment.

  Raises `Ecto.NoResultsError` if the Comment does not exist.

  ## Examples

      iex> get_comment!(123)
      %Comment{}

      iex> get_comment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_comment!(id), do: Repo.get!(Comment, id)

  @doc """
  Creates a comment.

  ## Examples

      iex> create_comment(%{field: value})
      {:ok, %Comment{}}

      iex> create_comment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_comment(attrs \\ %{}) do
    %Comment{}
    |> Comment.changeset(attrs)
    |> Repo.insert()
    |> broadcast_comment(:new_comment)
  end

  defp broadcast_comment({:error, _} = error, _event), do: error
  defp broadcast_comment({:ok, comment}, event) do
    Phoenix.PubSub.broadcast!(
      SonaComments.PubSub,
      @topic,
      {event, comment}
    )
    {:ok, comment}
  end

  @doc """
  Updates a comment.

  ## Examples

      iex> update_comment(comment, %{field: new_value})
      {:ok, %Comment{}}

      iex> update_comment(comment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_comment(%Comment{} = comment, attrs) do
    comment
    |> Comment.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a comment.

  ## Examples

      iex> delete_comment(comment)
      {:ok, %Comment{}}

      iex> delete_comment(comment)
      {:error, %Ecto.Changeset{}}

  """
  def delete_comment(%Comment{} = comment) do
    Repo.delete(comment)
  end

  def get_replies(parent_ids) do
    from(c in Comment, where: c.parent_id in ^parent_ids)
    |> Repo.all()
    |> Enum.group_by(& &1.parent_id)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking comment changes.

  ## Examples

      iex> change_comment(comment)
      %Ecto.Changeset{data: %Comment{}}

  """
  def change_comment(%Comment{} = comment \\ %Comment{}, attrs \\ %{}) do
    Comment.changeset(comment, attrs)
  end
end
