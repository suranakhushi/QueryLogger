defmodule QueryloggingWeb.Middleware.ErrorPropagator do
  alias Absinthe.Resolution

  @moduledoc """
  Middleware to propagate resolver errors to the resolution errors field.
  """

  def call(%Resolution{value: {:error, message}} = resolution, _config) do
    # Add the error to resolution.errors
    %{resolution | errors: resolution.errors ++ [%{message: message}]}
  end

  def call(resolution, _config), do: resolution
end
