defmodule MongoHang do
  use Application
  require Mongo

  def start(_type, _args) do
    config = [
      timeout: 4000,
      pool_timeout: 5000,
      connect_timeout_ms: 1000,
      read_preference: [mode: :primaryPreferred],
      name: :test_db,
      database: "test_db",
      hostname: "localhost",
      pool_size: 10
    ]

    children = [
      %{
        id: Mongo,
        start: {Mongo, :start_link, [config]}
      }
    ]

    opts = [strategy: :one_for_one, name: MongoHang.Supervisor]
    result = Supervisor.start_link(children, opts)

    {:ok} = ensure_collection()

    result
  end

  def ensure_collection() do
    collection_exists = collection_exists(:test_db, "test_collection")
    create_collection(:test_db, "test_collection", %{locale: "en"}, collection_exists)
  end

  defp create_collection(_pid, _coll, _collation, true) do
    {:ok}
  end

  defp create_collection(pid, coll, collation, false) do
    {:ok, _} = Mongo.command(pid, [create: coll, collation: collation], opts())
    {:ok}
  end

  def collection_exists(pid, coll) do
    {:ok, result} = Mongo.command(pid, [ listCollections: 1], opts())
    existing_collections = result["cursor"]["firstBatch"]
    Enum.any?(existing_collections, fn c -> c["name"] == coll end)
  end

  def opts() do
      [
        timeout: 4000,
        pool_timeout: 5000,
        connect_timeout_ms: 1000,
        pool_size: 20,
        read_preference: Mongo.ReadPreference.slave_ok(%{mode: :primary_preferred})
      ] end
end
