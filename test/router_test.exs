defmodule Example.RouterTest do
  use ExUnit.Case
  use Plug.Test
  alias Links.Router
  import Mox

  setup :verify_on_exit!

  @mimetype "application/json"
  @links ["https://a.com/news", "b.ru/1", "c.org"]
  @domains ["a.com", "b.ru", "c.org"]

  @opts Router.init([])

  describe "[GET] /visited_domains" do
    test "returns domains" do
      Links.MockRedis
      |> expect(:get, fn _from, _to ->
        {:ok, [Poison.encode!(%{"links" => @links})]}
      end)

      conn =
        :get
        |> conn("/visited_domains?from=1&to=2")
        |> Router.call(@opts)

      assert conn.state == :sent
      assert conn.status == 200

      body = Poison.decode!(conn.resp_body)
      assert body["status"] == "ok"
      assert body["domains"] == @domains
    end

    test "returns empty domains" do
      Links.MockRedis
      |> expect(:get, fn _from, _to ->
        {:ok, []}
      end)

      conn =
        :get
        |> conn("/visited_domains?from=1&to=2")
        |> Router.call(@opts)

      assert conn.state == :sent
      assert conn.status == 200

      body = Poison.decode!(conn.resp_body)
      assert body["status"] == "ok"
      assert body["domains"] == []
    end

    test "missing params" do
      conn =
        :get
        |> conn("/visited_domains")
        |> Router.call(@opts)

      assert conn.state == :sent
      assert conn.status == 400

      body = Poison.decode!(conn.resp_body)
      assert body["status"] == "Missing params"
    end
  end

  describe "[POST] /visited_links" do
    test "save links" do
      Links.MockRedis
      |> expect(:save, fn _ -> {:ok, "OK"} end)

      conn =
        :post
        |> conn("/visited_links", %{"links" => @links})
        |> put_req_header("content-type", @mimetype)
        |> Router.call(@opts)

      assert conn.state == :sent
      assert conn.status == 200

      body = Poison.decode!(conn.resp_body)
      assert body["status"] == "ok"
    end

    test "save links failed" do
      Links.MockRedis
      |> expect(:save, fn _ -> {:error, "error"} end)

      conn =
        :post
        |> conn("/visited_links", %{"links" => @links})
        |> put_req_header("content-type", @mimetype)
        |> Router.call(@opts)

      assert conn.state == :sent
      assert conn.status == 200

      body = Poison.decode!(conn.resp_body)
      assert body["status"] == "Failed to save"
    end

    test "missing links" do
      conn =
        :post
        |> conn("/visited_links", %{"links" => []})
        |> put_req_header("content-type", @mimetype)
        |> Router.call(@opts)

      assert conn.state == :sent
      assert conn.status == 400

      body = Poison.decode!(conn.resp_body)
      assert body["status"] == "No links"
    end

    test "bad request" do
      conn =
        :post
        |> conn("/visited_links", %{})
        |> put_req_header("content-type", @mimetype)
        |> Router.call(@opts)

      assert conn.state == :sent
      assert conn.status == 400

      body = Poison.decode!(conn.resp_body)
      assert body["status"] == "Bad request"
    end
  end

  test "returns 404" do
    conn =
      :get
      |> conn("/")
      |> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 404
    assert conn.resp_body == "Not found"
  end
end
