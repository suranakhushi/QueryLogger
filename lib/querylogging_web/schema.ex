defmodule QueryloggingWeb.Schema do
  use Absinthe.Schema

  query do
    field :hello, :string do
      middleware(QueryloggingWeb.Middleware.QueryLogger)
      resolve fn _, _, _ -> {:ok, "Hello, world!"} end
    end
  end
end
