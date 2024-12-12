# lib/querylogging/repo.ex
defmodule Querylogging.Repo do
  use Ecto.Repo,
    otp_app: :querylogging,
    adapter: Ecto.Adapters.Postgres
end
