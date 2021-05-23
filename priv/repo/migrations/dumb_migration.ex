defmodule WiktiScraperV2.Repo.Migrations.DumbMigration do
  use Ecto.Migration

  def change do
    alter table(:template) do
      modify :title, :array
    end

  end
end
