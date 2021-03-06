defmodule Mix.Tasks.Nomad.VirtualMachineInstance.Delete do
  use Mix.Task

  @moduledoc"""
  Task for automatically deleting a remote virtual machine on a
  pre-determined cloud provider. The instance deletion is done through
  the cloud provider's API.

  Usage:

    mix nomad.virtual_machine_instance.delete
    # Will be prompted for region and instance id or name

    mix nomad.virtual_machine_instance.delete <region> <name>
    # Won't be prompted for region and instance id
  """

  @shortdoc"Delete a virtual machine on the chosen cloud provider's infrastructure service."

  @provider Nomad.TasksHelper.get_provider

  @doc"""
  Runs the task for the chosen cloud provider. The shell prompts for the
  instance's name or id and informs of the results.
  """
  @spec run(args :: [binary] | []) :: binary
  def run(args) do
    Nomad.TasksHelper.start_apps_for_adapter(@provider)
    delete_instance_api_call args
  end

  defp delete_instance_api_call([]) do
    region = 
      case @provider do
        :gcl ->
          Mix.Shell.IO.prompt("Insert the instance's zone: ") |> String.rstrip
        :aws ->
          Mix.Shell.IO.prompt("Insert the instance's region: ") |> String.rstrip
      end
    name = Mix.Shell.IO.prompt("Insert the name of the instance you want to delete: ")
    |> String.rstrip

    del name, region
  end

  defp delete_instance_api_call([region, name]) do
    del name, region
  end

  defp del(name, region) do
    case Nomad.VirtualMachines.delete_virtual_machine(region, name) do
      :ok -> Mix.Shell.IO.info("The instance has been deleted successfully.")
      msg -> Mix.Shell.IO.info("There was a problem deleting the instance: \n#{msg}")
    end
  end
end
