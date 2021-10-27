defmodule Homer.Search.OfferRequest do
  use Ecto.Schema

  import Ecto.Changeset

  schema "offer_requests" do
    field :allowed_airlines, {:array, :string}
    field :departure_date, :date
    field :destination, :string
    field :origin, :string
    field :sort_by, Ecto.Enum, values: [:total_amount, :total_duration]

    timestamps()
  end

  @required ~w(origin destination departure_date)a
  @doc false
  def changeset(offer_request, attrs) do
    offer_request
    |> cast(attrs, [:sort_by, :allowed_airlines] ++ @required)
    |> validate_required(@required)
    |> validate_iata(:destination)
    |> validate_iata(:origin)
    |> update_change(:destination, &String.upcase(&1))
    |> update_change(:origin, &String.upcase(&1))
    |> clean_allowed_airlines
  end

  @iata_format ~r/^[a-zA-Z]{3}$/
  defp validate_iata(changeset, field) do
    changeset
    |> validate_change(field, fn _, field_value ->
      case Regex.match?(@iata_format, field_value) do
        true -> []
        false -> [{field, "unexpected IATA format - must be 3 letters"}]
      end
    end)
  end

  defp clean_allowed_airlines(changeset) do
    case get_change(changeset, :allowed_airlines) do
      nil ->
        changeset

      _ ->
        update_change(
          changeset,
          :allowed_airlines,
          &Enum.reject(&1, fn airline -> airline == "" end)
        )
    end
  end
end
