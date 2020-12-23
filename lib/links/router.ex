defmodule Links.Router do
  use Plug.Router

  alias Links.Controller

  plug(:match)
  plug(:dispatch)

  get "/visited_domains" do
    conn = fetch_query_params(conn)

    {status, body} =
      case conn.params do
        %{"from" => from, "to" => to} -> {200, Controller.get_domains(from, to)}
        _ -> {400, missing_params()}
      end

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, body)
  end

  post "/visited_links" do
    {status, body} =
      case conn.body_params do
        %{"links" => []} -> {400, missing_links()}
        %{"links" => links} -> {200, Controller.save_links(links)}
        _ -> {400, bad_request()}
      end

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, body)
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end

  defp missing_params() do
    Poison.encode!(%{status: "Missing params"})
  end

  defp missing_links() do
    Poison.encode!(%{status: "No links"})
  end

  defp bad_request() do
    Poison.encode!(%{status: "Bad request"})
  end
end
