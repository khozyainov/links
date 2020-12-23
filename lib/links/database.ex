defmodule Links.Database do
  @redis Application.get_env(:links, :redis)

  def save_links(links) do
    case @redis.save(links) do
      {:ok, _} -> :ok
      {:error, _} -> {:error, "Failed to save"}
    end
  end

  def get_links(from, to) do
    case @redis.get(from, to) do
      {:ok, saved_data} ->
        links =
          saved_data
          |> Enum.map(fn el ->
            %{"links" => links} = Poison.decode!(el)
            links
          end)
          |> List.flatten()

        {:ok, links}

      {:error, _} ->
        {:error, "Getting data failed"}
    end
  end
end
