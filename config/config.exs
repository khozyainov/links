use Mix.Config

redis_uri = System.get_env("REDIS_URI", "redis://localhost:6379")

config :links, :children, [
  Links.Endpoint,
  {Redix, {redis_uri, [name: :redix]}}
]

import_config "#{Mix.env()}.exs"
