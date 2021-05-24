defmodule WiktiScraperV2.Repo.Migrations.CreateWord do
  use Ecto.Migration

  def change do
    create table(:word) do
      add :lang, :string
      add :data, :map

      timestamps()
    end

  end
end
