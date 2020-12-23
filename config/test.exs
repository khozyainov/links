use Mix.Config

config :links, port: 4001
config :links, :redis, Links.MockRedis

config :links, :children, [
  Links.Endpoint
]
