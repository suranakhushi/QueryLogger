defmodule QueryloggingWeb.Router do
  use QueryloggingWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {QueryloggingWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", QueryloggingWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Correct setup for GraphiQL and GraphQL routes
  scope "/api" do
    pipe_through :api
    get "/export_query_logs", QueryloggingWeb.ExportController, :export_logs


    if Mix.env() == :dev do
      forward "/graphiql", Absinthe.Plug.GraphiQL, schema: QueryloggingWeb.Schema
    end
    forward "/graphql", Absinthe.Plug, schema: QueryloggingWeb.Schema
  end
  if Application.compile_env(:querylogging, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: QueryloggingWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
