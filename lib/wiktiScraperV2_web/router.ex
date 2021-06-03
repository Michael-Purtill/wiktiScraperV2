defmodule WiktiScraperV2Web.Router do
  use WiktiScraperV2Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", WiktiScraperV2Web do
    pipe_through :browser

    get "/", PageController, :index
    get "/lang/:lang", PageController, :lang
    get "/testPage/:lang/:word", PageController, :testpage
    get "/unmatched/:lang/:wordClass", PageController, :unmatched
  end

  scope "/api", WiktiScraperV2Web do
    pipe_through :api

    get "/langlist", ApiController, :langlist
    get "/posLinks/:lang", ApiController, :getPOSLinks
    get "/testPage/:lang/:word", ApiController, :testPage
    get "/wordInfo/:lang/:word", ApiController, :wordInfo
    post "/testPageJsonHandler", ApiController, :testPageJsonHandler
    post "/uploadTemplate", ApiController, :uploadTemplate
    post "/initUnmatched/:lang/:wordClass", ApiController, :initUnmatched
    get "/unmatched/:lang/:wordClass", ApiController, :getUnmatched
  end

  # Other scopes may use custom stacks.
  # scope "/api", WiktiScraperV2Web do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: WiktiScraperV2Web.Telemetry
    end
  end
end
