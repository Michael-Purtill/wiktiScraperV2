defmodule WiktiScraperV2.Template do
  use Ecto.Schema
  import Ecto.Changeset

  schema "template" do
    field :html, :string
    field :lang, :string
    field :selectors, :map
    field :wordclass, :string

    timestamps()
  end

  @doc false
  def changeset(template, attrs) do
    template
    |> cast(attrs, [:lang, :wordclass, :html, :selectors])
    |> validate_required([:lang, :wordclass, :html, :selectors])
  end
end
