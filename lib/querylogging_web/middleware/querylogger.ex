defmodule QueryloggingWeb.Middleware.QueryLogger do
  require Logger
  alias Querylogging.Repo
  alias Querylogging.QueryLogEntry
  import Ecto.Query, only: [from: 2]

  def call(resolution, _) do
    db_logging = Application.get_env(:querylogging, :db_logging, false)
    query_string = resolution.definition.name
    variables = resolution.context[:absinthe_variables] || %{}
    Logger.debug("Query String: #{query_string}, Variables: #{inspect(variables)}")
    start_time = System.monotonic_time()
    result = resolution
    end_time = System.monotonic_time()
    execution_time = System.convert_time_unit(end_time - start_time, :native, :millisecond)

    # Log resolution errors and result value for tracing
    Logger.debug("Resolution Errors: #{inspect(resolution.errors)}")
    Logger.debug("Result Value: #{inspect(result.value)}")

    error_message =
      if Enum.empty?(resolution.errors) do
        "No Errors"
      else
        resolution.errors
        |> Enum.map(&inspect(&1))
        |> Enum.join(", ")
      end



    # Log the error message before proceeding
    Logger.debug("Error Message: #{error_message}")

    changeset =
      %QueryLogEntry{}
      |> QueryLogEntry.changeset(%{
        query_string: query_string,
        execution_time: execution_time,
        error_message: error_message,
        created_at: DateTime.utc_now() |> DateTime.truncate(:second),
        updated_at: DateTime.utc_now() |> DateTime.truncate(:second)
      })

    # Log the generated changeset for validation
    Logger.debug("Generated Changeset: #{inspect(changeset)}")

    if db_logging do
      case Repo.insert(changeset) do
        {:ok, entry} ->
          Logger.debug("Successfully logged #{entry.id} to database")
        {:error, changeset_error} ->
          Logger.error("Failed to log query: #{inspect(changeset_error)}")
      end
    end


    #query = from q in QueryLogEntry, select: q
    #for item <- Repo.all(query) do
    #  Logger.debug("Recent DB Entry: #{inspect(item)}")
    #end

    result
  end
end
