defmodule WiktiScraperV2.Word do
  use Ecto.Schema
  import Ecto.Changeset

  schema "word" do
    field :data, :map
    field :lang, :string

    timestamps()
  end

  @doc false
  def changeset(word, attrs) do
    word
    |> cast(attrs, [:lang, :data])
    |> validate_required([:lang, :data])
  end
end
