defmodule ManagementWeb.Router do
  use ManagementWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {ManagementWeb.LayoutView, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", ManagementWeb do
    pipe_through(:browser)

    live("/", PageLive, :index)

    ##### Account live views #####
    live("/accounts", AccountLive.Index, :index)
    live("/accounts/new", AccountLive.Index, :new)
    live("/accounts/:id/edit", AccountLive.Index, :edit)

    live("/accounts/:id", AccountLive.Show, :show)
    live("/accounts/:id/show/edit", AccountLive.Show, :edit)

    ########### Writer Profile live view routes ##############
    live("/writer_profiles", WriterProfileLive.Index, :index)
    live("/writer_profiles/new", WriterProfileLive.Index, :new)
    live("/writer_profiles/:id/edit", WriterProfileLive.Index, :edit)

    live("/writer_profiles/:id", WriterProfileLive.Show, :show)
    live("/writer_profiles/:id/show/edit", WriterProfileLive.Show, :edit)

    ############### Account Owner Live view Routes #####################
    live("/owners", OwnerLive.Index, :index)
    live("/owners/new", OwnerLive.Index, :new)
    live("/owners/:id/edit", OwnerLive.Index, :edit)

    live("/owners/:id", OwnerLive.Show, :show)
    live("/owners/:id/show/edit", OwnerLive.Show, :edit)

    ############# Jobs liveview routes ##################################
    live "/jobs", JobLive.Index, :index
    live "/jobs/new", JobLive.Index, :new
    live "/jobs/:id/edit", JobLive.Index, :edit

    live "/jobs/:id", JobLive.Show, :show
    live "/jobs/:id/show/edit", JobLive.Show, :edit
  end

  # Other scopes may use custom stacks.
  # scope "/api", ManagementWeb do
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
      pipe_through(:browser)
      live_dashboard("/dashboard", metrics: ManagementWeb.Telemetry)
    end
  end
end
