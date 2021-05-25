defmodule WiktiScraperV2.Repo.Migrations.CreateUnmatchedWord do
  use Ecto.Migration

  def change do
    create table(:unmatched_word) do
      add :lang, :string
      add :pos, :string
      add :html, :text

      timestamps()
    end

  end
end
