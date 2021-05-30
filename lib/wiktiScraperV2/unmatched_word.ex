defmodule WiktiScraperV2.UnmatchedWord do
  use Ecto.Schema
  import Ecto.Changeset

  schema "unmatched_word" do
    field :html, :string
    field :lang, :string
    field :pos, :string
    field :link, :string

    timestamps()
  end

  @doc false
  def changeset(umatched_word, attrs) do
    umatched_word
    |> cast(attrs, [:lang, :pos, :html])
    |> validate_required([:lang, :pos, :html])
  end
end
