defmodule Nomad.DeploymentScript do

  ### THIS FILE SHOULD BE WRITTEN TO TEMP????
  def build_script do 
    {:ok, script} = File.open "after_deploy.sh", [:write]

    IO.binwrite script, bs("app", System.get_env("USERNAME"), System.get_env("APP_NAME"))
    File.close script
  end

  defp bs(folder, username, app_name) do 
    "sudo mkdir -p /#{folder}\n" <>
    "sudo chown #{username}:#{username} /#{folder}\n" <>
    "cd /#{folder}\n" <>
    "tar xfz /root/#{app_name}.tar.gz\n"
  end

  def delete_script do 
    File.rm("after_deploy.sh")
  end
end