defmodule Mix.Tasks.Nomad.Storage.Delete do
  use Mix.Task

  @moduledoc"""
  Task for automatically deleting a remote storage on a pre-determined cloud
  provider. The storage deletion is done through the cloud provider's API.

  Usage:

    mix nomad.storage.delete
    # Will be prompted for storage name

    mix nomad.storage.delete <name>
    # Will automaticallu delete the storage
  """

  @shortdoc"Create a storage on the chosen cloud provider's storage service."

  @provider Nomad.TasksHelper.get_provider

  def run(args) do
    Nomad.TasksHelper.start_apps_for_adapter(@provider)
    delete_storage_api_call args
  end

  defp delete_storage_api_call([name]) do
   del name 
  end

  defp delete_storage_api_call([]) do
    name = Mix.Shell.IO.prompt("Insert the storage's name: ") |> String.rstrip

    del name
  end

  defp del(name) do
    case Nomad.Storage.delete_storage(name) do
      :ok -> Mix.Shell.IO.info("The instance has been deleted successfully.") 
      msg -> Mix.Shell.IO.info("There was a problem deleting the storage: \n#{msg}")
    end
  end
end
