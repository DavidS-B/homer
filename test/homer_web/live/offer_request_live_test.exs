defmodule HomerWeb.OfferRequestLiveTest do
  use HomerWeb.ConnCase

  import Phoenix.LiveViewTest
  import Homer.SearchFixtures

  @create_attrs %{
    departure_date: %{day: 20, month: 10, year: 2021},
    destination: "Abv",
    origin: "CCC"
  }
  @invalid_create_attrs %{
    departure_date: %{day: 30, month: 2, year: 2021},
    destination: nil,
    origin: nil
  }
  @update_attrs %{
    allowed_airlines: ["American Airlines Group"],
    sort_by: "total_duration"
  }

  defp create_offer_request(_) do
    offer_request = offer_request_fixture()
    %{offer_request: offer_request}
  end

  describe "Index" do
    setup [:create_offer_request]

    test "lists all offer_requests", %{conn: conn, offer_request: offer_request} do
      {:ok, _index_live, html} = live(conn, Routes.offer_request_index_path(conn, :index))

      assert html =~ "Listing offer requests"
      assert html =~ offer_request.destination
    end

    test "saves new offer_request", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.offer_request_index_path(conn, :index))

      assert index_live |> element("a", "New offer request") |> render_click() =~
               "New offer request"

      assert_patch(index_live, Routes.offer_request_index_path(conn, :new))

      assert index_live
             |> form("#offer_request-form", offer_request: @invalid_create_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        index_live
        |> form("#offer_request-form", offer_request: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.offer_request_index_path(conn, :index))

      assert html =~ "Offer request created successfully"
      assert html =~ "ABV"
    end

    test "deletes offer_request in listing", %{conn: conn, offer_request: offer_request} do
      {:ok, index_live, _html} = live(conn, Routes.offer_request_index_path(conn, :index))

      assert index_live
             |> element("#offer_request-#{offer_request.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#offer_request-#{offer_request.id}")
    end
  end

  describe "Show" do
    setup [:create_offer_request]

    test "displays offers", %{conn: conn, offer_request: offer_request} do
      {:ok, _show_live, html} =
        live(conn, Routes.offer_request_show_path(conn, :show, offer_request))

      assert html =~ "Show offers"
      assert html =~ offer_request.destination
    end

    test "updates offer_request within modal", %{conn: conn, offer_request: offer_request} do
      {:ok, show_live, html} =
        live(conn, Routes.offer_request_show_path(conn, :show, offer_request))

      assert html =~ "total_amount"
      refute html =~ "total_duration"

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit offer request"

      assert_patch(show_live, Routes.offer_request_show_path(conn, :edit, offer_request))

      {:ok, _, html} =
        show_live
        |> form("#offer_request-form", offer_request: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.offer_request_show_path(conn, :show, offer_request))

      assert html =~ "Offer request updated successfully"
      refute html =~ "total_amount"
      assert html =~ "total_duration"
    end
  end
end
