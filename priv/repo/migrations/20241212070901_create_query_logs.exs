defmodule Querylogging.Repo.Migrations.CreateQueryLogs do
  use Ecto.Migration

  def change do
    create table(:query_logs) do
      add :query_string, :string
      add :execution_time, :integer
      add :error_message, :string
      add :created_at, :utc_datetime, default: fragment("CURRENT_TIMESTAMP")
      add :updated_at, :utc_datetime
    end
  end
end
