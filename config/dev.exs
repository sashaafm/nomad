use Mix.Config

config :nomad,
	ssh_key: :empty,
  target_host: System.get_env("HOST"),
  target_port: System.get_env("PORT")

case System.get_env("PROVIDER") do
  "GCL" ->
     config :goth, 
     	json: "config/creds.json" |> Path.expand |> File.read!

    config :gcloudex,
      project:  "330132837690"  

  "AWS" ->
    :ok
end
