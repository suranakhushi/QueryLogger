defmodule QueryloggingWeb.ExportController do
  use QueryloggingWeb, :controller
  alias Querylogging.Repo
  alias Querylogging.QueryLogEntry
  alias Querylogging.QueryLogExporter

  def export_logs(conn, _params) do

    query_logs = Repo.all(QueryLogEntry)

    QueryLogExporter.export_to_csv(query_logs)
    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=query_logs.csv")
    |> send_file(200, QueryLogExporter.csv_file_path())
  end
end
