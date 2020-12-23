defmodule Links.RedisApi do
  @callback save(any) :: {:ok, any} | {:error, any}
  @callback get(any, any) :: {:ok, any} | {:error, any}
end

defmodule Links.Redis do
  @behaviour Links.RedisApi

  @key "links"

  def save(links) do
    timestamp = System.system_time(:second)

    Redix.command(:redix, [
      "ZADD",
      @key,
      timestamp,
      Poison.encode!(%{links: links, timestamp: timestamp})
    ])
  end

  def get(from, to) do
    Redix.command(:redix, ["ZRANGEBYSCORE", @key, from, to])
  end
end
