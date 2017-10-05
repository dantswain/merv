defmodule MervUiWeb.PageController do
  use MervUiWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
