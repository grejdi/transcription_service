defmodule Api.Request do
  use Ecto.Schema

  schema "request" do
    field(:uuid, Ecto.UUID)
    field(:status, :string)
  end
end
