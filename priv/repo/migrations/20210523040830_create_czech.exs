defmodule WiktiScraperV2.Repo.Migrations.CreateCzech do
  use Ecto.Migration

  def change do
    create table(:czech) do
      add :data, :map

      timestamps()
    end

  end
end
