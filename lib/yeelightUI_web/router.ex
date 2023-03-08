defmodule YeelightUIWeb.Router do
  use YeelightUIWeb, :router

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
  

  scope "/", YeelightUIWeb do
    pipe_through :browser
    get "/", LightsController, :index
    resources "/lights", LightsController, only: [:index, :show, :update, :create, :edit]
    if Mix.env() in [:dev, :test] do
      import Phoenix.LiveDashboard.Router
      live_dashboard "/dashboard", metrics: YeelightUIWeb.Telemetry
    end
  end
end
