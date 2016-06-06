defmodule Mix.Tasks.Nomad.DatabaseInstance.Restart do
  use Mix.Task
  
  @moduledoc """
  Task for automatically restarting a remote SQL database on a pre-determined
  cloud provider. The instance reboot is done through the cloud provider's
  API.

  Usage:
    
    mix nomad.database_instance.restart 
      # Will be prompted for name 

    mix nomad.database_instance.restart <name>  
      # Won't be prompted for name
  """

  @shortdoc "Restart a SQL database instance on the chosen cloud provider's SQL service."

  @doc """
  Runs the task for the chosen cloud provider. The shell prompts for the 
  instance's name if no name was passed as an argument.
  """
  @spec run(list) :: binary
  def run(args) do 
    case Application.get_env(:nomad, :cloud_provider) do 
      :aws -> 
        Application.ensure_all_started(:ex_aws)
        Application.ensure_all_started(:httpoison)
      :gcl -> 
        Application.ensure_all_started(:httpoison)
        Application.ensure_all_started(:goth)
        Application.ensure_all_started(:gcloudex)
    end
        
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
