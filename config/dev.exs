use Mix.Config

config :nomad,
	ssh_key: :empty,
  target_host: System.get_env("HOST"),
  target_port: System.get_env("PORT")

config :nomad_gcl,
  #storage_client_id: "330132837690-ims0fdl4hvc6unj8rvk3arhnhoh5386h.apps.googleusercontent.com",
  #storage_client_secret: "Z5uIgfvra8kYaFaRVaNCzDRs",
  #storage_redirect_uri: "urn:ietf:wg:oauth:2.0:oob",
  #response_type: "token",
  storage_scope: "https://www.googleapis.com/auth/devstorage.full_control"#,
  #storage_auth_code: "4/0I6ywrpGqucCUsfl1Tqs6mXYW00K-aJVlJk_sGsZ4Fw"

 config :goth, 
 	json: "config/creds.json" |> Path.expand |> File.read!
