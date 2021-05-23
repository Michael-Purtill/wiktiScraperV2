defmodule WiktiScraperV2.Czech do
  use Ecto.Schema
  import Ecto.Changeset

  schema "czech" do
    field :data, :map

    timestamps()
  end

  @doc false
  def changeset(czech, attrs) do
    czech
    |> cast(attrs, [:data])
    |> validate_required([:data])
  end
end
