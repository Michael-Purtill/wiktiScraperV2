defmodule WiktiScraperV2.Repo.Migrations.CreateTemplate do
  use Ecto.Migration

  def change do
    create table(:template) do
      add :lang, :string
      add :wordclass, :string
      add :html, :string
      add :selectors, :map

      timestamps()
    end

  end
end
