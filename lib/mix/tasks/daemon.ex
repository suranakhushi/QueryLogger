defmodule Mix.Tasks.QueryLogger.Daemon do
  use Mix.Task

  @shortdoc "Starts the query logging daemon with optional database logging"

  @moduledoc """
  Starts the query logging daemon.

  ## Examples

      mix query_logger.daemon
      mix query_logger.daemon --db true

  ## Options
  - `--db true`: Enables database logging in addition to CSV logging.
  """

  def run(args) do
    Mix.Task.run("app.start")

    # Parse CLI arguments to override config
    db_logging = parse_args(args)

    Querylogging.CLI.Daemon.start(db: db_logging)
  end

  defp parse_args(args) do
    case OptionParser.parse(args, switches: [db: :boolean]) do
      {opts, _, _} -> Keyword.get(opts, :db, nil) # nil means "use config default"
      _ -> nil
    end
  end
end
