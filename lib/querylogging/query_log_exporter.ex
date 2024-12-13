defmodule Querylogging.QueryLogExporter do
  require Logger
  alias CSV

  @csv_file "query_logs.csv"

  def export_to_csv(query_logs) do
    # Ensure the file exists with headers
    unless File.exists?(@csv_file) do
      headers = ["query_string", "execution_time", "error_message", "created_at", "updated_at"]
      write_to_csv(headers)
    end

    # Format data for CSV
    formatted_logs =
      Enum.map(query_logs, fn
        %{} = log -> [
          log.query_string,
          log.execution_time,
          log.error_message || "No errors", # Include error message
          log.created_at,
          log.updated_at
        ]
        _ -> nil # Ignore invalid data
      end)
      |> Enum.reject(&is_nil/1) # Remove nil values

    # Write each log to the CSV
    Enum.each(formatted_logs, &write_to_csv/1)
    Logger.info("Query logs exported to #{@csv_file}")
  end

  defp write_to_csv(data) do
    File.open(@csv_file, [:append, :utf8], fn file ->
      CSV.encode([data]) |> Enum.each(&IO.write(file, &1))
    end)
  end

  def csv_file_path, do: @csv_file
end
