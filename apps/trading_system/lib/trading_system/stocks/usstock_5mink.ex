defmodule TradingSystem.Stocks.USStock5MinK do
  use Ecto.Schema
  import Ecto.Changeset
  alias TradingSystem.Stocks.USStock5MinK


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "usstock_5mink" do
    field :close_price, :decimal
    field :datetime, :naive_datetime
    field :highest_price, :decimal
    field :lowest_price, :decimal
    field :open_price, :decimal
    field :symbol, :string
    field :volume, :integer

    timestamps()
  end

  @doc false
  def changeset(%USStock5MinK{} = us_stock5_min_k, attrs) do
    us_stock5_min_k
    |> cast(attrs, [:symbol, :datetime, :open_price, :close_price, :lowest_price, :highest_price, :volume])
    |> validate_required([:symbol, :datetime, :open_price, :close_price, :lowest_price, :highest_price, :volume])
  end
end
