defmodule WiktiScraperV2.Repo.Migrations.DumbMigration2 do
  use Ecto.Migration

  def change do
    alter table(:unmatched_word) do
      add :matched, :boolean
    end

  end
end
