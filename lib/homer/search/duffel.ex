defmodule Homer.Search.Duffel do
  @moduledoc """
  This module interact with the Duffel API.
  """

  use Timex

  import Ecto.Query, warn: false

  alias Homer.Utils.DTUtils
  alias Homer.Search
  alias Homer.Search.{OfferRequest, Offer}

  @duffel_access_token "duffel_test_5Y4tsFQfoTbdbgo0oScb6riWhUPqGvrCoAEdFase8lv"
  @duffel_url "https://api.duffel.com/air/offer_requests"
  @timex_parse "{YYYY}-{0M}-{0D}T{h24}:{m}:{s}"
  @request_timeout 50_000

  @doc """
  Make an offer request to the Duffel API and store offers in the DB.
  """
  @callback fetch_offers(OfferRequest.t()) :: {:ok, [Offer.t()]} | {:error, any()}
  def fetch_offers(%OfferRequest{} = offer_request) do
    token = @duffel_access_token
    url = @duffel_url

    headers = [
      "Accept-Encoding": "gzip",
      Accept: "application/json",
      "Content-Type": "application/json",
      "Duffel-Version": "beta",
      Authorization: "Bearer #{token}"
    ]

    body =
      Jason.encode!(%{
        data: %{
          slices: [
            %{
              origin: offer_request.origin,
              destination: offer_request.destination,
              departure_date: offer_request.departure_date
            }
          ],
          passengers: [%{type: "adult"}],
          cabin_class: "economy"
        }
      })

    case HTTPoison.post(url, body, headers,
           timeout: @request_timeout,
           recv_timeout: @request_timeout
         ) do
      {:ok, response} ->
        [:zlib.gunzip(response.body)]
        |> Jaxon.Stream.from_enumerable()
        |> Jaxon.Stream.query(Jaxon.Path.parse!("$.data.offers[*]"))
        |> Flow.from_enumerable()
        |> Flow.map(fn offer ->
          segments = hd(offer["slices"])["segments"]
          departing_at = Timex.parse!(hd(segments)["departing_at"], @timex_parse)
          arriving_at = Timex.parse!(hd(Enum.reverse(segments))["arriving_at"], @timex_parse)
          total_amount = String.to_float(offer["total_amount"])
          total_duration = DTUtils.pt_to_minutes(hd(offer["slices"])["duration"])

          %{
            origin: offer_request.origin,
            destination: offer_request.destination,
            departing_at: departing_at,
            arriving_at: arriving_at,
            segments_count: length(segments),
            total_amount: total_amount,
            total_duration: total_duration
          }
        end)
        |> Enum.each(fn offer -> Search.create_offer(offer) end)

      error ->
        {:error, error}
    end
  end
end
