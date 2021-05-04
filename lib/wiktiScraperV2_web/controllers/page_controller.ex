defmodule WiktiScraperV2Web.PageController do
  use WiktiScraperV2Web, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def lang(conn, %{"lang" => lang}) do
    render(conn, "lang.html")
  end

  def testpage(conn, _params) do
    render(conn, "testpage.html")
  end
end
