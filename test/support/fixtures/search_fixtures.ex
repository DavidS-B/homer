defmodule Homer.SearchFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Homer.Search` context.
  """

  @doc """
  Generate an offer_request.
  """
  def offer_request_fixture(attrs \\ %{}) do
    {:ok, offer_request} =
      attrs
      |> Enum.into(%{
        departure_date: ~D[2021-10-20],
        destination: "aAe",
        origin: "bbZ"
      })
      |> Homer.Search.create_offer_request()

    offer_request
  end

  @doc """
  Generate an offer.
  """
  def offer_fixture(attrs \\ %{}) do
    {:ok, offer} =
      attrs
      |> Enum.into(%{
        arriving_at: ~N[2021-10-21 04:00:07],
        departing_at: ~N[2021-10-20 23:00:07],
        destination: "AAE",
        origin: "BBZ",
        segments_count: 2,
        total_amount: 20.6,
        total_duration: 240
      })
      |> Homer.Search.create_offer()

    offer
  end
end
