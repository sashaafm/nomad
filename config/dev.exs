use Mix.Config

config :nomad,
	ssh_key: :empty,
  target_host: System.get_env "HOST",
  target_port: System.get_env "PORT"