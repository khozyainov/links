use Mix.Config

config :links, :redis_uri, System.get_env("REDIS_URI")

import_config "#{Mix.env()}.exs"
