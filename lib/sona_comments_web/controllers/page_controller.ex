defmodule SonaCommentsWeb.PageController do
  use SonaCommentsWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
