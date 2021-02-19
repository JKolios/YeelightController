defmodule YeelightUIWeb.PageController do
  use YeelightUIWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
