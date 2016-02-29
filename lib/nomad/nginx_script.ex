defmodule Nomad.NginxScript do

  @moduledoc """
  
  """

  def build_script do 
    {:ok, script} = File.open "#{System.get_env("APP_NAME")}", [:write]

    :ok = IO.binwrite script, bs(System.get_env("APP_NAME"), 
                                 System.get_env("HOST"), 
                                 System.get_env("PORT"))
    File.close script
  end

  defp bs(app_name, host, port) do 
    """
    upstream #{app_name} {
      server 127.0.0.1:#{port};
    }
    # The following map statement is required
    # if you plan to support channels. See https://www.nginx.com/blog/websocket-nginx/
    map $http_upgrade $connection_upgrade {
      default upgrade;
      '' close;
    }
    server{
      listen 80;
      server_name #{host};

      location / {
        try_files $uri @proxy;
      }

      location @proxy {
        include proxy_params;
        proxy_redirect off;
        proxy_pass http://#{app_name};
        # The following two headers need to be set in order
        # to keep the websocket connection open. Otherwise you'll see
        # HTTP 400's being returned from websocket connections.
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
      }
    }
    """
  end

  def delete_script do 
    File.rm "#{System.get_env("APP_NAME")}"
  end
  
end