defmodule Links.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = Application.get_env(:links, :children)

    opts = [strategy: :one_for_one, name: Links.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
