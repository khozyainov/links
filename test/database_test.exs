defmodule Links.DatabaseTest do
  use ExUnit.Case, async: true
  alias Links.Database
  import Mox

  setup :verify_on_exit!

  @links ["a.com", "b.ru", "c.org"]

  test "save links" do
    Links.MockRedis
    |> expect(:save, 2, fn _ -> {:ok, "OK"} end)

    assert :ok == Database.save_links([])
    assert :ok == Database.save_links(@links)
  end

  test "save links failed" do
    Links.MockRedis
    |> expect(:save, 2, fn _ -> {:error, "error"} end)

    assert {:error, "Failed to save"} == Database.save_links([])
    assert {:error, "Failed to save"} == Database.save_links(@links)
  end

  test "get links" do
    Links.MockRedis
    |> expect(:get, fn _from, _to ->
      {:ok, [Poison.encode!(%{"links" => @links})]}
    end)

    assert {:ok, @links} == Database.get_links("1", "2")
  end

  test "get links failed" do
    Links.MockRedis
    |> expect(:get, fn _from, _to ->
      {:error, "error"}
    end)

    assert {:error, "Getting data failed"} == Database.get_links("1", "2")
  end
end
