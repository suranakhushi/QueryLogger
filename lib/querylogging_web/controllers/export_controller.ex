defmodule QueryloggingWeb.ExportController do
  use QueryloggingWeb, :controller
  alias Querylogging.Repo
  alias Querylogging.QueryLogEntry
  alias Querylogging.QueryLogExporter

  def export_logs(conn, _params) do
    # Fetch logs from the database
    query_logs = Repo.all(QueryLogEntry)

    # Generate CSV file
    QueryLogExporter.export_to_csv(query_logs)

    # Serve the file as a downloadable attachment
    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=query_logs.csv")
    |> send_file(200, QueryLogExporter.csv_file_path())
  end
end
