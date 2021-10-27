defmodule Homer.Search do
  @moduledoc """
  The Search context.
  """

  import Ecto.Query, warn: false

  alias Homer.Repo
  alias Homer.Search.{Offer, OfferRequest}

  @default_airlines ["Delta Air Lines", "American Airlines Group"]

  @doc """
  Returns the list of offer_requests.

  ## Examples

      iex> list_offer_requests()
      [%OfferRequest{}, ...]

  """
  @callback list_offer_requests() :: [OfferRequest.t()]
  def list_offer_requests do
    from(o in OfferRequest, order_by: [asc: o.departure_date])
    |> Repo.all()
  end

  @doc """
  Gets a single offer_request.

  Raises `Ecto.NoResultsError` if the Offer request does not exist.

  ## Examples

      iex> get_offer_request!(123)
      %OfferRequest{}

      iex> get_offer_request!(456)
      ** (Ecto.NoResultsError)

  """
  @callback get_offer_request!(id :: integer()) :: [OfferRequest.t()]
  def get_offer_request!(id) do
    Repo.get!(OfferRequest, id)
  end

  @doc """
  Creates a offer_request.

  ## Examples

      iex> create_offer_request(%{field: value})
      {:ok, %OfferRequest{}}

      iex> create_offer_request(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @callback create_offer_request(attrs :: map()) :: {:ok, OfferRequest.t()} | {:error, any()}
  def create_offer_request(attrs) do
    attrs = %{
      "origin" => Map.get(attrs, :origin) || Map.get(attrs, "origin"),
      "destination" => Map.get(attrs, :destination) || Map.get(attrs, "destination"),
      "departure_date" => Map.get(attrs, :departure_date) || Map.get(attrs, "departure_date"),
      "allowed_airlines" => @default_airlines,
      "sort_by" => "total_amount"
    }

    %OfferRequest{}
    |> OfferRequest.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a offer_request.

  ## Examples

      iex> update_offer_request(offer_request, %{field: new_value})
      {:ok, %OfferRequest{}}

      iex> update_offer_request(offer_request, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @callback update_offer_request(OfferRequest.t(), attrs :: map()) ::
              {:ok, OfferRequest.t()} | {:error, any()}
  def update_offer_request(%OfferRequest{} = offer_request, attrs) do
    attrs = %{
      "allowed_airlines" =>
        Map.get(attrs, :allowed_airlines) || Map.get(attrs, "allowed_airlines"),
      "sort_by" => Map.get(attrs, :sort_by) || Map.get(attrs, "sort_by")
    }

    offer_request
    |> OfferRequest.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a offer_request.

  ## Examples

      iex> delete_offer_request(offer_request)
      {:ok, %OfferRequest{}}

      iex> delete_offer_request(offer_request)
      {:error, %Ecto.Changeset{}}

  """
  @callback delete_offer_request(OfferRequest.t()) :: {:ok, OfferRequest.t()} | {:error, any()}
  def delete_offer_request(%OfferRequest{} = offer_request) do
    Repo.delete(offer_request)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking offer_request changes.

  ## Examples

      iex> change_offer_request(offer_request)
      %Ecto.Changeset{data: %OfferRequest{}}

  """
  @callback change_offer_request(OfferRequest.t(), attrs :: map()) ::
              Ecto.Changeset.t() | {:error, any()}
  def change_offer_request(%OfferRequest{} = offer_request, attrs \\ %{}) do
    OfferRequest.changeset(offer_request, attrs)
  end

  @doc """
  Creates offer.

  ## Examples

      iex> create_offer(%{field: value})
      {:ok, %Offer{}}

      iex> create_offer(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @callback create_offer(attrs :: map()) :: {:ok, Offer.t()} | {:error, any()}
  def create_offer(attrs) do
    %Offer{}
    |> Offer.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns a limited list of offers for a given offer_request.

  ## Examples

      iex> get_offers(offer_request, limit)
      [%Offer{}, ...]

  """
  @callback get_offers(OfferRequest.t(), integer()) :: [Offer.t()]
  def get_offers(%OfferRequest{} = offer_request, limit \\ 10) do
    {:ok, departure_date} = NaiveDateTime.new(offer_request.departure_date, ~T[00:00:00])

    from(o in Offer,
      where:
        o.origin == ^offer_request.origin and o.destination == ^offer_request.destination and
          o.departing_at >= ^departure_date,
      order_by: [asc: ^offer_request.sort_by],
      limit: ^limit
    )
    |> Repo.all()
  end

  @doc """
  Delete all offers entries.
  """
  def delete_offers() do
    Repo.delete_all(Offer)
  end
end
