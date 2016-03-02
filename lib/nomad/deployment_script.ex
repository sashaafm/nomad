defmodule Nomad.DeploymentScript do
  @behaviour Script

  @moduledoc """
  
  """

  @folder "app"

  ### THIS FILE SHOULD BE WRITTEN TO TEMP????
  def build_script do
    {:ok, script} = File.open "after_deploy.sh", [:write]

    :ok = IO.binwrite script, bs
    File.close script
  end

  defp bs do
    """
    sudo mkdir -p /#{@folder}
    sudo chown #{System.get_env("USERNAME")}:#{System.get_env("USERNAME")} /#{@folder}
    cd /#{@folder}
    tar xfz /root/#{System.get_env("APP_NAME")}.tar.gz
    sudo touch /etc/nginx/sites-available/#{System.get_env("APP_NAME")}
    sudo ln -s /etc/nginx/sites-available/#{System.get_env("APP_NAME")} /etc/nginx/sites-enabled
    sudo service nginx stop
    sudo start #{System.get_env("APP_NAME")}
    sudo service nginx start
    """
  end

  def delete_script do
    File.rm "after_deploy.sh"
  end
end