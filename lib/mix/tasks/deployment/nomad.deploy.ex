defmodule Mix.Tasks.Nomad.Deploy do
  use Mix.Task
  alias Nomad.{RemoteDeploy}

  @moduledoc """
  Task for automatically deploying production releases of Elixir and 
  Phoenix applications to remote hosts. This task is mainly targeted at cloud
  hosts like Amazon EC2 instances or Google Compute Engine instances, but will
  work with any UNIX remote machine.

  The deployment is done through SSH and it follows the officials guidelines at 
  www.phoenixframework.org.
  """

  @shortdoc"""
  Automatically deploys a production release of the appplication on a remote host.
  """
  
  @doc """
  Deploy the application in the current project's directory.
  Arguments must be in order:
  HOSTNAME/IP : Required - the remote host hostname or IP address 
  PORT        : Required - the port for the production application
  SSH KEY     : Required - the SSH Key for accessing the remote host,
                             only the filename and it must be in ~/.ssh 
  USERNAME    : Required - the username to use to access the remote host
  -f          : Optional - bypass all the questions during deployment
  """
  def run(args) do
    setup_config args

    if ("-f" in args) == false do 
      if Mix.Shell.IO.yes? "A production release will be generated, do you wish to proceed?" do 
        compile_and_gen_release
      else
        Mix.Shell.IO.info "Deployment halted at the user's request."
        System.halt
      end
    else
      compile_and_gen_release
    end

    if ("-f" in args) == false do 
      if Mix.Shell.IO.yes? "The release will now be sent to the remote host, do you agree?" do
        RemoteDeploy.run
      else
        Mix.Shell.IO.info "Deployment halted at the user's request."
        System.halt
      end
    else
      RemoteDeploy.run
    end
  end

  defp setup_config(args) do 
    {:ok, host}     = Enum.fetch(args, 0)
    {:ok, port}     = Enum.fetch(args, 1)
    {:ok, username} = Enum.fetch(args, 2)
    {:ok, ssh_key}  = Enum.fetch(args, 3)

    System.put_env              "HOST",     host
    System.put_env              "PORT",     port
    System.put_env              "USERNAME", username
    # Getting the app name from the cwd may not always work?
    System.put_env              "APP_NAME", System.cwd |> String.split("/") |> List.last
    Application.put_env         :nomad,     :ssh_key, ssh_key
  end

  defp compile_and_gen_release do 
    Mix.env :prod
    Mix.Task.run "phoenix.digest"
    Mix.Task.run "compile"
    Mix.Task.run "release"
  end
end
