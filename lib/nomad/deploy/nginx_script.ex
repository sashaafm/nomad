defmodule Nomad.NginxScript do
  @behaviour Script

  @moduledoc """
  Builds and deletes the NGINX script for the production release.
  """

  @doc """
  Builds the script for the setup of NGINX to use the production release of the application.
  The script follows the Phoenix Official EXRM Releases Guide.
  """
  def build_script do 
    {:ok, script} = File.open "#{System.get_env("APP_NAME")}", [:write]

    :ok = IO.binwrite script, bs
    File.close script
  end

  defp bs do 
    """
    upstream #{System.get_env("APP_NAME")} {
      server 127.0.0.1:#{System.get_env("PORT")};
    }
    # The following map statement is required
    # if you plan to support channels. See https://www.nginx.com/blog/websocket-nginx/
    map $http_upgrade $connection_upgrade {
      default upgrade;
      '' close;
    }
    server{
      listen 80;
      server_name #{System.get_env("HOST")};

      location / {
        try_files $uri @proxy;
      }

      location @proxy {
        include proxy_params;
        proxy_redirect off;
        proxy_pass http://#{System.get_env("APP_NAME")};
        # The following two headers need to be set in order
        # to keep the websocket connection open. Otherwise you'll see
        # HTTP 400's being returned from websocket connections.
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
      }
    }
    """
  end

  @doc """
  Deletes the NGINX script from the local directory.
  """
  def delete_script do 
    File.rm "#{System.get_env("APP_NAME")}"
  end
  
end