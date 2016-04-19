defmodule Mix.Tasks.Nomad.DatabaseInstance.Restart do
  use Mix.Task
  
  @moduledoc """
  Task for automatically restarting a remote SQL database on a pre-determined
  cloud provider. The instance reboot is done through the cloud provider's
  API.

  Usage:
    
    PROVIDER=<cloud_provider> mix nomad.database_instance.restart 
      # Will be prompted for name 

    PROVIDER=<cloud_provider> mix nomad.database_instance.restart <name>  
      # Won't be prompted for name
  """

  @shortdoc"""
  Restart a SQL database instance on the chosen cloud provider's SQL service.  
  """

  @doc """
  Runs the task for the chosen cloud provider. The shell prompts for the 
  instance's name if no name was passed as an argument.
  """
  @spec run(list) :: binary
  def run(args) do 
    case System.get_env("PROVIDER") do 
      "AWS" -> restart_instance_aws args

      "GCL" -> restart_instance_gcl args
    end
  end

  defp restart_instance_aws(args) do 
    Application.ensure_all_started :nomad_aws

    restart_instance_api_call args
  end

  defp restart_instance_gcl(args) do 
    Application.ensure_all_started :nomad_gcl

    restart_instance_api_call args
  end

  # When no args are provided the prompt asks for the instance's name
  defp restart_instance_api_call([]) do 
    name = Mix.Shell.IO.prompt("Insert the name of the instance you want to restart: ")
    |> String.rstrip

    del name
  end

  # When a name is provided the API call is made directly
  defp restart_instance_api_call([name]) do 
    del name
  end

  defp del(name) do 
    case Nomad.SQL.restart_instance(name) do 
      :ok -> 
        Mix.Shell.IO.info("The instance has been restarted successfully.")
      msg -> 
        Mix.Shell.IO.info("There was a problem restarting the instance:\n#{msg}")
    end      
  end
end