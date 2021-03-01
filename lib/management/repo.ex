defmodule Management.Repo do
  use Ecto.Repo,
    otp_app: :management,
    adapter: Ecto.Adapters.Postgres
end
