defmodule WiktiScraperV2.UnmatchedWord do
  use Ecto.Schema
  import Ecto.Changeset

  schema "unmatched_word" do
    field :html, :string
    field :lang, :string
    field :pos, :string
    field :link, :string
    field :matched, :boolean

    timestamps()
  end

  @doc false
  def changeset(umatched_word, attrs) do
    umatched_word
    |> cast(attrs, [:lang, :pos, :html, :link, :matched])
    |> validate_required([:lang, :pos, :html, :link, :matched])
  end
end
