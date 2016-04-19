defmodule Mix.Tasks.Nomad.DatabaseInstance.List do
  use Mix.Task

  @moduledoc """
  Task for automatically listing all remote SQL databases on a pre-determined
  cloud provider. The instance listing is done through the cloud provider's
  API.

  Usage:
    
    PROVIDER=<cloud_provider> mix nomad.database_instance.list 
  """

  @shortdoc"""
  Lists all SQL database instances on the chosen cloud provider's SQL service.
  """

  @doc """
  Runs the task for the chosen cloud provider.
  """
  @spec run(list) :: binary
  def run(args) do 
    case System.get_env("PROVIDER") do 
      "AWS" -> list_instances_aws args

      "GCL" -> list_instances_gcl args
    end
  end

  defp list_instances_aws(_args) do
    Application.ensure_all_started :nomad_aws

    list_instances_api_call
  end

  defp list_instances_gcl(_args) do 
    Application.ensure_all_started :nomad_gcl

    list_instances_api_call
  end

  defp list_instances_api_call do
    res = Nomad.SQL.list_instances

    if is_list(res) do 
      res = res
      |> convert_instance_tuples_to_lists
      |> stringify

      TableRex.quick_render!(
        res, 
        ["Name", "Region", "Address", "Status", "Storage"],
        "List of SQL Database Instances on #{System.get_env("PROVIDER")}")
      |> Mix.Shell.IO.info
    else
      Mix.Shell.IO.info("There was a problem listing the instances:\n#{res}")
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