defmodule Mix.Tasks.Nomad.VirtualMachineInstance.Restart do
  use Mix.Task

  @moduledoc"""
  Task for automatically restarting a virtual machine instance on
  a pre-determined cloud provider. The instance reboot is done through the
  cloud provider's API.

  Usage:

    mix nomad.virtual_machine_instance.restart
    # Will be prompted for region and instance id or name

    mix nomad.virtual_machine_instance.restart <region> <name>
    # Won't be promted for region and instance id
  """

  @shortdoc "Restart a virtual machine on the chosen cloud provider's infrastructure service."

  @provider Nomad.TasksHelper.get_provider

  @doc"""
  Runs the task for the chosen cloud provider. The shell prompts for the
  instance's region and name if the data wasn't passed through the arguments.
  """
  @spec run(args :: [binary] | []) :: binary
  def run(args) do
    Nomad.TasksHelper.start_apps_for_adapter(@provider)
    restart_instance_api_call args
  end

  defp restart_instance_api_call([]) do
    region = 
      case @provider do
        :gcl ->
          Mix.Shell.IO.prompt("Insert the instance's zone: ") |> String.rstrip
        :aws ->
          Mix.Shell.IO.prompt("Insert the instance's region: ") |> String.rstrip
      end
    name = Mix.Shell.IO.prompt("Insert the name of the instance you want to delete: ")
    |> String.rstrip

    restart name, region
  end

  defp restart_instance_api_call([region, name]) do
    restart name, region
  end

  defp restart(name, region) do
    case Nomad.VirtualMachines.reboot_virtual_machine(region, name) do
      :ok -> 
        Mix.Shell.IO.info("The instance has been restarted successfully.")
      msg ->
        Mix.Shell.IO.info("There was a problem restarting the instance:\n#{msg}")
    end
  end
end 
