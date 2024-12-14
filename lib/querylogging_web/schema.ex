defmodule QueryloggingWeb.Schema do
  use Absinthe.Schema

  query do
    # Existing `hello` field
    field :hello, :string do
      middleware(QueryloggingWeb.Middleware.ErrorPropagator)
      middleware(QueryloggingWeb.Middleware.QueryLogger)
      resolve fn _, _, _ -> {:error, "Intentional error for debugging"} end

    end

    # New field to trigger errors
    field :error_field, :string do
      middleware(QueryloggingWeb.Middleware.ErrorPropagator)
      middleware(QueryloggingWeb.Middleware.QueryLogger)
      resolve fn _, _, _ -> {:error, "This is a test error"} end
    end
  end
end
