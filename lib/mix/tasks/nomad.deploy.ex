defmodule Mix.Tasks.Nomad.Deploy do
  use Mix.Task
  alias Nomad.{DeploymentScript}

  @moduledoc """
  
  """
  
  def run(args) do
    setup_config args

    if ("-f" in args) == false do 
      case Mix.Shell.IO.yes? "A production release will be generated, do you wish to proceed?" do 
        true  -> compile_and_gen_release
        false -> 
          Mix.Shell.IO.info "Deployment halted at the user's request."
          System.halt
        _     -> System.halt
      end
    else
      #compile_and_gen_release
    end

    if ("-f" in args) == false do 
      case Mix.Shell.IO.yes? "The release will now be sent to the cloud host, do you agree?" do
        true  -> cloud_deploy
        false -> 
          Mix.Shell.IO.info "Deployment halted at the user's request."
          System.halt
        _     -> System.halt
      end
    else
      cloud_deploy
    end
                   
    cleanup
  end

  defp setup_config(args) do 
    {:ok, host}     = Enum.fetch(args, 0)
    {:ok, port}     = Enum.fetch(args, 1)
    {:ok, username} = Enum.fetch(args, 2)
    {:ok, ssh_key}  = Enum.fetch(args, 3)

    System.put_env              "HOST",     host
    System.put_env              "PORT",     port
    System.put_env              "USERNAME", username
    # Getting the app name from the cwd may not always work!
    System.put_env              "APP_NAME", System.cwd |> String.split("/") |> List.last
    Application.put_env         :nomad,     :ssh_key, ssh_key
  end

  defp compile_and_gen_release do 
    Mix.env :prod
    Mix.Task.run "compile"
    Mix.Task.run "release"
  end

  defp cloud_deploy do 
    build_deployment_script
    deploy_to_cloud_host
    transfer_deployment_script
    execute_remote_deployment_script
  end

  defp deploy_to_cloud_host do
    System.cmd "scp", [
                       "-i", "~/.ssh/#{Application.get_env(:nomad, :ssh_key)}.pub", 
                       "rel/#{System.get_env("APP_NAME")}/releases/0.0.1/"
                       <> "#{System.get_env("APP_NAME")}.tar.gz", 
                       "#{System.get_env("USERNAME")}@#{System.get_env("HOST")}:/root"
                      ]                       
  end

  defp transfer_deployment_script do 
    Mix.Shell.IO.info "Going to transfer the after deployment script."
    System.cmd "scp", [
                       "-i", "~/.ssh/#{Application.get_env(:nomad, :ssh_key)}.pub", 
                       "after_deploy.sh", 
                       "#{System.get_env("USERNAME")}@#{System.get_env("HOST")}:/root"
                      ]
  end

  defp execute_remote_deployment_script do
    Mix.Shell.IO.info "Going to run the remote script."                                             
    System.cmd "ssh", ["#{System.get_env("USERNAME")}@#{System.get_env("HOST")}", 
                       "chmod o+rx after_deploy.sh;" 
                       <> "./after_deploy.sh"
                      ]
  end

  defp build_deployment_script do
    DeploymentScript.build_script
  end

  defp cleanup do 
    Mix.Shell.IO.info("Remove release from local dir.")
    System.cmd "rm", ["-rf", "rel"]
    DeploymentScript.delete_script
  end
end