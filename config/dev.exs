use Mix.Config

config :nomad,
	target_host: System.get_env("HOST"),
	target_port: {:system, "PORT"}