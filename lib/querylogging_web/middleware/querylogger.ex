defmodule QueryloggingWeb.Middleware.QueryLogger do
  require Logger
  alias Querylogging.Repo
  alias Querylogging.QueryLogEntry
  import Ecto.Query, only: [from: 2]

  def call(resolution, _) do
    query_string = resolution.definition.name
    variables = resolution.context[:absinthe_variables] || %{}
    Logger.debug("Query String: #{query_string}, Variables: #{inspect(variables)}")
    start_time = System.monotonic_time()


    result = resolution

    end_time = System.monotonic_time()


    execution_time = System.convert_time_unit(end_time - start_time, :native, :millisecond)


    error_message =
      if resolution.errors != [] do
        "Query failed: #{inspect(resolution.errors)}"
      else
        "No Errors"
      end


    changeset =
      %QueryLogEntry{}
      |> QueryLogEntry.changeset(%{
        query_string: query_string,
        execution_time: execution_time,
        error_message: error_message,
        created_at: DateTime.utc_now() |> DateTime.truncate(:second),
        updated_at: DateTime.utc_now() |> DateTime.truncate(:second)


      })

    raw_entry = %QueryLogEntry{
      query_string: query_string,
        execution_time: execution_time,
        error_message: error_message,
        created_at: DateTime.utc_now() |> DateTime.truncate(:second),
        updated_at: DateTime.utc_now() |> DateTime.truncate(:second)
    }
    #Logger.debug("Changeset: #{changeset}")
    case Repo.insert(raw_entry) do
      {:ok, entry} ->
        Logger.debug("Successfully logged #{entry.id} to database")
      {:error, changeset_error} ->
        Logger.error("Failed to log query: #{inspect(changeset_error)}")
        Logger.error("Changeset details: #{inspect(changeset)}")
    end
    query = from q in QueryLogEntry, select: q
    for item <- Repo.all(query) do
      Logger.debug(item)
    end
    result
  end
end
