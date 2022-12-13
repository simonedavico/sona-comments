defmodule SonaComments.Repo do
  use Ecto.Repo,
    otp_app: :sona_comments,
    adapter: Ecto.Adapters.Postgres
end
