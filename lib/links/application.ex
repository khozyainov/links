defmodule Links.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    redis_uri = Application.get_env(:links, :redis_uri)

    children = [
      {Redix, {redis_uri, [name: :redix]}},
      Links.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Links.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
