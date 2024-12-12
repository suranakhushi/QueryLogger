# lib/querylogging/query_log_entry.ex
defmodule Querylogging.QueryLogEntry do
  use Ecto.Schema
  import Ecto.Changeset

  schema "query_logs" do
    field :query_string, :string
    field :execution_time, :integer
    field :error_message, :string, default: nil
    field :created_at, :utc_datetime, default: DateTime.utc_now() |> DateTime.truncate(:second)
    field :updated_at, :utc_datetime, default: DateTime.utc_now() |> DateTime.truncate(:second)
  end

  def changeset(query_log_entry, attrs) do
    query_log_entry
    |> cast(attrs, [:query_string, :execution_time, :error_message, :created_at, :updated_at])
    |> validate_required([:query_string, :execution_time])
  end
end
