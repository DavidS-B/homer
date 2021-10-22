defmodule Homer.SearchTest do
  use Homer.DataCase

  alias Homer.Search

  describe "offer_requests" do
    alias Homer.Search.OfferRequest

    import Homer.SearchFixtures

    @default_airlines ["Delta Air Lines", "American Airlines Group"]
    @invalid_attrs %{
      allowed_airlines: nil,
      departure_date: nil,
      destination: nil,
      origin: nil,
      sort_by: nil
    }

    test "list_offer_requests/0 returns all offer_requests" do
      offer_request = offer_request_fixture()
      assert Search.list_offer_requests() == [offer_request]
    end

    test "get_offer_request!/1 returns the offer_request with given id" do
      offer_request = offer_request_fixture()
      assert Search.get_offer_request!(offer_request.id) == offer_request
    end

    test "create_offer_request/1 with valid data creates a offer_request" do
      valid_attrs = %{
        departure_date: ~D[2021-10-20],
        destination: "Muy",
        origin: "dbz"
      }

      assert {:ok, %OfferRequest{} = offer_request} = Search.create_offer_request(valid_attrs)
      assert offer_request.allowed_airlines == @default_airlines
      assert offer_request.departure_date == ~D[2021-10-20]
      assert offer_request.destination == "MUY"
      assert offer_request.origin == "DBZ"
      assert offer_request.sort_by == :total_amount
    end

    test "create_offer_request/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Search.create_offer_request(@invalid_attrs)
    end

    test "update_offer_request/2 with valid data updates the offer_request" do
      offer_request = offer_request_fixture()
      departure_date = ~D[2021-10-20]
      destination = "AAE"
      origin = "BBZ"
      allowed_airlines_update = [hd(@default_airlines)]
      sort_by_update = "total_duration"

      assert offer_request.allowed_airlines == @default_airlines
      assert offer_request.departure_date == departure_date
      assert offer_request.destination == destination
      assert offer_request.origin == origin
      assert offer_request.sort_by == :total_amount

      update_attrs = %{
        allowed_airlines: allowed_airlines_update,
        sort_by: sort_by_update
      }

      assert {:ok, %OfferRequest{} = offer_request} =
               Search.update_offer_request(offer_request, update_attrs)

      assert offer_request.allowed_airlines == allowed_airlines_update
      assert offer_request.departure_date == departure_date
      assert offer_request.destination == destination
      assert offer_request.origin == origin
      assert offer_request.sort_by == String.to_atom(sort_by_update)
    end

    test "update_offer_request/2 with invalid data returns error changeset" do
      offer_request = offer_request_fixture()

      invalid_update_attrs = %{
        allowed_airlines: 123,
        sort_by: <<42::8>>
      }

      assert {:error, %Ecto.Changeset{}} =
               Search.update_offer_request(offer_request, invalid_update_attrs)

      assert offer_request == Search.get_offer_request!(offer_request.id)

      invalid_allowed_airlines_update_attrs = %{
        allowed_airlines: "oops"
      }

      assert {:error, %Ecto.Changeset{}} =
               Search.update_offer_request(offer_request, invalid_allowed_airlines_update_attrs)

      assert offer_request == Search.get_offer_request!(offer_request.id)

      invalid_sort_by_update_attrs = %{
        sort_by: "total_toto"
      }

      assert {:error, %Ecto.Changeset{}} =
               Search.update_offer_request(offer_request, invalid_sort_by_update_attrs)

      assert offer_request == Search.get_offer_request!(offer_request.id)
    end

    test "delete_offer_request/1 deletes the offer_request" do
      offer_request = offer_request_fixture()
      assert {:ok, %OfferRequest{}} = Search.delete_offer_request(offer_request)
      assert_raise Ecto.NoResultsError, fn -> Search.get_offer_request!(offer_request.id) end
    end

    test "change_offer_request/1 returns a offer_request changeset" do
      offer_request = offer_request_fixture()
      assert %Ecto.Changeset{} = Search.change_offer_request(offer_request)
    end
  end
end
