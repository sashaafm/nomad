defmodule Nomad.DeploymentScript do

  @moduledoc """
  
  """

  ### THIS FILE SHOULD BE WRITTEN TO TEMP????
  def build_script do
    {:ok, script} = File.open "after_deploy.sh", [:write]

    :ok = IO.binwrite script, bs("app", System.get_env("USERNAME"), System.get_env("APP_NAME"))
    File.close script
  end

  defp bs(folder, username, app_name) do
    """
    sudo mkdir -p /#{folder}
    sudo chown #{username}:#{username} /#{folder}
    cd /#{folder}
    tar xfz /root/#{app_name}.tar.gz
    sudo touch /etc/nginx/sites-available/#{app_name}
    sudo ln -s /etc/nginx/sites-available/#{app_name} /etc/nginx/sites-enabled
    sudo service nginx stop
    sudo start #{app_name}
    sudo service nginx start
    """
  end

  def delete_script do
    File.rm "after_deploy.sh"
  end
end