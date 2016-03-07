use Mix.Config

config :nomad,
	ssh_key: :empty,
  target_host: System.get_env("HOST"),
  target_port: System.get_env("PORT")

config :nomad_gcl,
  storage_scope: "https://www.googleapis.com/auth/devstorage.full_control"

 config :goth, 
 	json: "config/creds.json" |> Path.expand |> File.read!

config :gcloudex,
  storage_scope: "https://www.googleapis.com/auth/devstorage.full_control",
  storage_proj:  "330132837690"  
