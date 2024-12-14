defmodule Querylogging.Repo.Migrations.AddInsertedAtToQueryLogs do
  use Ecto.Migration

  def change do
    alter table(:query_logs) do
      add :inserted_at, :utc_datetime, default: fragment("NOW()"), null: false
    end
  end
end
