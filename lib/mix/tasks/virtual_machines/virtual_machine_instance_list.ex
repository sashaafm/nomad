defmodule Mix.Tasks.Nomad.VirtualMachineInstance.List do
  use Mix.Task

  @moduledoc"""
  Task for automatically listing all remote Virtual Machine instances on a
  pre-determined cloud provider. The instance listing is done through the cloud
  provider's API.

  Usage:

    mix nomad.virtual_machine_instance.list
  """

  @shortdoc"Lists all virtual machines on the chosen cloud provider's infrastructure service in the given region."

  @provider Application.get_env(:nomad, :cloud_provider)

  @doc"""
  Runs the task for the chosen cloud provider.
  """
  @spec run(args :: [binary] | []) :: binary
  def run(args) do
    case @provider do
      :aws ->
        Application.ensure_all_started(:ex_aws)
        Application.ensure_all_started(:httpoison)
      :gcl ->
        Application.ensure_all_started(:httpoison)
        Application.ensure_all_started(:goth)
        Application.ensure_all_started(:gcloudex)
    end
    
    list_instances_api_call args
  end

  defp list_instances_api_call([region]) do
    provider =
      case @provider do
        :aws -> "Amazon Web Services"
        :gcl -> "Google Cloud Platform"
      end
    res = Nomad.VirtualMachines.list_virtual_machines region

    if is_list(res) && res != [] do
      res = res
      |> convert_instance_tuples_to_lists
      |> stringify

      TableRex.quick_render!(
        res,
        ["Name", "Status", "Machine Type", "Public IP"],
        "Virtual Machines on #{provider}")
      |> Mix.Shell.IO.info
    else
      if res == [] do
        Mix.Shell.IO.info("There are no instances to be listed.")
      else
        Mix.Shell.IO.info("There was a problem listing the instances:\n#{res}")
      end
    end
  end

  defp convert_instance_tuples_to_lists(instances) do
    instances 
    |> Enum.map(fn instance -> Tuple.to_list(instance) end)    
  end

  defp stringify(rows) do
    Enum.map rows, fn row ->
      Enum.map(row, &to_string/1)
    end
  end
end
