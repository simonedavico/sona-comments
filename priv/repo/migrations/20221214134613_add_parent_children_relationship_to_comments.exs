defmodule SonaComments.Repo.Migrations.AddParentChildrenRelationshipToComments do
  use Ecto.Migration

  def change do
    alter table(:comments) do
      add :parent_id, references(:comments)
    end
  end
end
