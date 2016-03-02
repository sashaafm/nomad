defmodule Mix.Tasks.Nomad.Deploy do
  use Mix.Task
  alias Nomad.{RemoteDeploy}

  @moduledoc """
  
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
    # Getting the app name from the cwd may not always work!
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