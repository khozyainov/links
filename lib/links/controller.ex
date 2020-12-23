defmodule Links.Controller do
  alias Links.Database

  def get_domains(from, to) do
    case Database.get_links(from, to) do
      {:ok, links} ->
        domains =
          links
          |> Enum.map(&extract_domain/1)
          |> Enum.uniq()

        Poison.encode!(%{"domains" => domains, "status" => "ok"})

      {:error, error} ->
        Poison.encode!(%{status: error})
    end
  end

  def save_links(links) do
    case Database.save_links(links) do
      :ok -> Poison.encode!(%{status: :ok})
      {:error, error} -> Poison.encode!(%{status: error})
    end
  end

  defp extract_domain(link) do
    case URI.parse(link) do
      %URI{scheme: nil} -> extract_domain("http://#{link}")
      parsed -> parsed.host
    end
  end
end
