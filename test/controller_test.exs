defmodule Example.ControllerTest do
  use ExUnit.Case, async: true
  import Mox
  alias Links.Controller

  setup :verify_on_exit!

  @links ["https://a.com/news", "b.ru/1", "c.org"]
  @domains ["a.com", "b.ru", "c.org"]

  describe "get_domains/2" do
    test "returns domains successfully" do
      Links.MockRedis
      |> expect(:get, fn _from, _to ->
        {:ok, [Poison.encode!(%{"links" => @links})]}
      end)

      domains =
        Controller.get_domains("1", "2")
        |> Poison.decode!()

      assert domains["status"] == "ok"
      assert domains["domains"] == @domains
    end

    test "returns empty domains" do
      Links.MockRedis
      |> expect(:get, fn _from, _to ->
        {:ok, []}
      end)

      domains =
        Controller.get_domains("1", "2")
        |> Poison.decode!()

      assert domains["status"] == "ok"
      assert domains["domains"] == []
    end

    test "get domains failed" do
      Links.MockRedis
      |> expect(:get, fn _from, _to ->
        {:error, "error"}
      end)

      domains =
        Controller.get_domains("1", "2")
        |> Poison.decode!()

      assert domains["status"] == "Getting data failed"
    end
  end

  describe "save_links/1" do
    test "saves links successfully" do
      Links.MockRedis
      |> expect(:save, fn _links -> {:ok, "OK"} end)

      domains =
        Controller.save_links(@links)
        |> Poison.decode!()

      assert domains["status"] == "ok"
    end

    test "save links failed" do
      Links.MockRedis
      |> expect(:save, fn _links -> {:error, "error"} end)

      domains =
        Controller.save_links(@links)
        |> Poison.decode!()

      assert domains["status"] == "Failed to save"
    end
  end
end
