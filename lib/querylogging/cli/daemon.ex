defmodule Querylogging.CLI.Daemon do
  @moduledoc """
  A CLI daemon to log GraphQL queries into a CSV file and optionally into the database.
   mix query_logger.daemon

  Supports:
  - Continuous background mode: Logs queries live to CSV and optionally to the database.
  - One-time session: Creates a new CSV file for the session and logs queries interactively.
  """

  alias Querylogging.QueryLogExporter
  alias Querylogging.Repo
  alias Querylogging.QueryLogEntry

  require Logger

  @csv_file "query_logs.csv"

  ## Starts the continuous background daemon
  def start(opts \\ []) do
    Logger.info("Starting Query Logging Daemon...")

    db_logging =
      case Keyword.get(opts, :db) do
        nil -> Application.get_env(:querylogging, :daemon)[:db_logging] # Use config default
        value -> value # Use CLI override
      end

    Logger.info("Database logging is #{if db_logging, do: "enabled", else: "disabled"}.")

    # Ensure the CSV file exists with headers
    ensure_csv_headers()

    # Start a continuous task to listen for queries
    Task.start(fn -> continuous_listener(db_logging) end)
  end

  ## Continuous listener for queries
  defp continuous_listener(db_logging) do
    mock_queries = [
      %{query_string: "getUser", execution_time: 100, error_message: nil, created_at: DateTime.utc_now(), updated_at: DateTime.utc_now()},
      %{query_string: "getOrders", execution_time: 250, error_message: "Timeout error", created_at: DateTime.utc_now(), updated_at: DateTime.utc_now()}
    ]

    for query <- Stream.cycle(mock_queries) do
      log_to_csv(query)

      if db_logging do
        log_to_db(query)
      end

      :timer.sleep(5000) # Simulate delay between queries
    end
  end

  ## Starts a one-time session
  def start_one_time_session(opts \\ []) do
    Logger.info("Starting One-Time Query Logging Session...")

    db_logging = Keyword.get(opts, :db, false)

    mock_queries = [
      %{query_string: "getUser", execution_time: 100, error_message: nil, created_at: DateTime.utc_now(), updated_at: DateTime.utc_now()},
      %{query_string: "getOrders", execution_time: 250, error_message: "Timeout error", created_at: DateTime.utc_now(), updated_at: DateTime.utc_now()}
    ]

    unique_csv_file = "session_query_logs_#{DateTime.utc_now() |> DateTime.to_string() |> String.replace(" ", "_")}.csv"

    for query <- mock_queries do

      formatted_query = [
        query.query_string,
        query.execution_time,
        query.error_message || "No errors",
        query.created_at,
        query.updated_at
      ]

      File.open(unique_csv_file, [:append, :utf8], fn file ->
        CSV.encode([formatted_query]) |> Enum.each(&IO.write(file, &1))
      end)

      Logger.debug("Inserted into CSV: #{inspect(formatted_query)}")

      if db_logging do
        log_to_db(query)
      else
        Logger.info("Database logging skipped.")
      end
    end
  end

  ## Ensure the CSV file exists with headers
  defp ensure_csv_headers do
    unless File.exists?(@csv_file) do
      headers = ["query_string", "execution_time", "error_message", "created_at", "updated_at"]
      QueryLogExporter.export_to_csv([headers])
      Logger.debug("Inserted headers into CSV: #{inspect(headers)}")
    end
  end

  ## Logs query details to a CSV file
  defp log_to_csv(query) do
    formatted_query = [
      query.query_string,
      query.execution_time,
      query.error_message || "No errors",
      query.created_at,
      query.updated_at
    ]

    QueryLogExporter.export_to_csv([formatted_query])
    Logger.debug("Inserted into CSV: #{inspect(formatted_query)}")
  end

  ## Logs query details to the database
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
        Logger.debug("Inserted into DB: #{inspect(entry)}")
        Logger.info("Logged query to DB with ID: #{entry.id}")
      {:error, error} ->
        Logger.error("Failed to log query to DB: #{inspect(error)}")
    end
  end
end
