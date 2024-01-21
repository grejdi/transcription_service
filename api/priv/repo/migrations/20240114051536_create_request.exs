defmodule Api.Repo.Migrations.CreateRequest do
  use Ecto.Migration

  def change do
    create table(:request) do
      add :uuid, :uuid, null: false
      add :status, :string
    end
  end
end
