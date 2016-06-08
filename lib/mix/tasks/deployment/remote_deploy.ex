defmodule Nomad.RemoteDeploy do
  alias Nomad.{DeploymentScript, UpstartScript, NginxScript, RemoteSetupScript}

  @moduledoc """
  Transfers the production release to the remote host and sets up the 
  host's environment, the application and the remote NGINX Web Server.
  """
  
  @doc """
  Deploys the production release to the remote host.
  """
  def run do 
    {_, 0} =
      if Mix.Shell.IO.yes? "Do you want to setup the remote host?" do
        :ok    = build_remote_setup_script
        {_, 0} = transfer_remote_setup_script 
        execute_remote_setup_script
      end

    :ok    = build_deployment_script
    :ok    = build_upstart_script
    :ok    = build_nginx_script
    {_, 0} = deploy_to_remote_host 
    {_, 0} = transfer_deployment_script 
    {_, 0} = transfer_upstart_script 
    {_, 0} = transfer_nginx_script 
    {_, 0} = execute_remote_deployment_script
    :ok    = local_cleanup
    remote_cleanup
  end

  defp deploy_to_remote_host do
    System.cmd "scp", [
                       "-i",
                       System.get_env("SSH_KEY"),
                       "rel/#{System.get_env("APP_NAME")}/releases/0.0.1/#{System.get_env("APP_NAME")}.tar.gz", 
                       "#{System.get_env("USERNAME")}@#{System.get_env("HOST")}:/home/#{System.get_env("USERNAME")}"
                      ]                       
  end

  defp transfer_deployment_script do 
    Mix.Shell.IO.info "Going to transfer the after deployment script."
    System.cmd "scp", [
                       "-i",
                       System.get_env("SSH_KEY"), 
                       "after_deploy.sh", 
                       "#{System.get_env("USERNAME")}@#{System.get_env("HOST")}:/home/#{System.get_env("USERNAME")}"
                      ]
  end

  defp transfer_upstart_script do
    Mix.Shell.IO.info "Going to transfer the Upstart script."
    System.cmd "scp", [
                       "-i",
                       System.get_env("SSH_KEY"), 
                       "#{System.get_env("APP_NAME")}.conf", 
                       "#{System.get_env("USERNAME")}@#{System.get_env("HOST")}:/etc/init"
                      ]    
  end

  defp transfer_nginx_script do
    Mix.Shell.IO.info "Going to transfer the NGINX script."
    System.cmd "scp", [
                       "-i",
                       System.get_env("SSH_KEY"),
                       "#{System.get_env("APP_NAME")}", 
                       "#{System.get_env("USERNAME")}@#{System.get_env("HOST")}:/etc/nginx/sites-available"
                      ]    
  end

  defp transfer_remote_setup_script do 
    Mix.Shell.IO.info "Going to transfer the remote setup script."
    IO.inspect System.get_env("SSH_KEY")
    System.cmd "scp", [
                       "-i",
                       System.get_env("SSH_KEY"),
                       "remote_setup.sh", 
                       "#{System.get_env("USERNAME")}@#{System.get_env("HOST")}:/home/#{System.get_env("USERNAME")}"
                      ]      
  end  

  defp execute_remote_setup_script do 
    Mix.Shell.IO.info "Going to run the remote setup script."                                             
    System.cmd "ssh", [
                       "-i",
                       System.get_env("SSH_KEY"),
                       "#{System.get_env("USERNAME")}@#{System.get_env("HOST")}", 
                       "chmod 700 remote_setup.sh;./remote_setup.sh"
                      ]    
  end

  defp execute_remote_deployment_script do
    Mix.Shell.IO.info "Going to run the remote script."                                             
    System.cmd "ssh", [
                       "-i",
                       System.get_env("SSH_KEY"),
                       "#{System.get_env("USERNAME")}@#{System.get_env("HOST")}", 
                       "chmod 700 after_deploy.sh;./after_deploy.sh"
                      ]
  end

  defp build_deployment_script do
    DeploymentScript.build_script
  end

  defp build_remote_setup_script do 
    RemoteSetupScript.build_script
  end

  defp build_upstart_script do 
    UpstartScript.build_script
  end

  defp build_nginx_script do 
    NginxScript.build_script
  end

  defp local_cleanup do 
    Mix.Shell.IO.info "Cleaning up local dir."
    {_, 0} = System.cmd "rm", ["-rf", "rel"]
    :ok    = DeploymentScript.delete_script
    :ok    = UpstartScript.delete_script
    :ok    = RemoteSetupScript.delete_script
  end

  defp remote_cleanup do 
    Mix.Shell.IO.info "Cleaning up remote dir."
    System.cmd "ssh", ["#{System.get_env("USERNAME")}@#{System.get_env("HOST")}",
                       "rm -rf after_deploy.sh #{System.get_env("APP_NAME")}.tar.gz"
                      ]
  end  
end
