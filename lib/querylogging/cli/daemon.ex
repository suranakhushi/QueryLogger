defmodule Querylogging.CLI.Daemon do
  @moduledoc """
  A CLI daemon to log GraphQL queries into a CSV file and optionally into the database.
  """

  alias Querylogging.QueryLogExporter
  alias Querylogging.Repo
  alias Querylogging.QueryLogEntry

  require Logger

  @csv_file "daemon_query_logs.csv"

  def start(opts \\ []) do
    Logger.info("Starting Query Logging Daemon...")

    # Respect configuration if CLI option is not explicitly passed
    db_logging =
      case Keyword.get(opts, :db) do
        nil -> Application.get_env(:querylogging, :daemon)[:db_logging] # Use config default
        value -> value # Use CLI override
      end

    Logger.info("Database logging is #{if db_logging, do: "enabled", else: "disabled"}.")

    # Ensure the CSV file exists and has headers
    ensure_csv_headers()

    # Start listening for queries
    listen_for_queries(db_logging)
  end

  # Ensure the CSV file exists and includes headers
  defp ensure_csv_headers do
    unless File.exists?(@csv_file) do
      headers = ["query_string", "execution_time", "error_message", "created_at", "updated_at"]
      QueryLogExporter.export_to_csv([headers])
    end
  end

  # Simulate listening for GraphQL queries and log them
  defp listen_for_queries(db_logging) do
    mock_queries = [
      %{query_string: "getUser", execution_time: 100, error_message: nil, created_at: DateTime.utc_now(), updated_at: DateTime.utc_now()},
      %{query_string: "getOrders", execution_time: 250, error_message: "Timeout error", created_at: DateTime.utc_now(), updated_at: DateTime.utc_now()}
    ]

    for query <- mock_queries do
      log_to_csv(query)

      if db_logging do
        log_to_db(query)
      else
        Logger.info("Database logging is disabled.")
      end

      :timer.sleep(2000) # Simulate delay
    end
  end

  # Log query details to a CSV file
  defp log_to_csv(query) do
    formatted_query = [
      query.query_string,
      query.execution_time,
      query.error_message || "No errors", # Default message for logs without errors
      query.created_at,
      query.updated_at
    ]

    QueryLogExporter.export_to_csv([formatted_query])
    Logger.info("Logged query to CSV: #{inspect(formatted_query)}")
  end

  # Log query details to the database
  defp log_to_db(query) do
    changeset = QueryLogEntry.changeset(%QueryLogEntry{}, %{
      query_string: query.query_string,
      execution_time: query.execution_time,
      error_message: query.error_message,
      created_at: query.created_at,
      updated_at: query.updated_at
    })

    case Repo.insert(changeset) do
      {:ok, entry} ->
        Logger.info("Logged query to DB with ID: #{entry.id}")
      {:error, error} ->
        Logger.error("Failed to log query to DB: #{inspect(error)}")
    end
  end
end
