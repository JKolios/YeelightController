defmodule YeelightUIWeb.LightsControllerTest do
  use YeelightUIWeb.ConnCase

  test "GET /lights", %{conn: conn} do
    conn = get(conn, "/lights")
    assert html_response(conn, 200) =~ "<html>"
  end
end
