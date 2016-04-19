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
      columnar = res
      |> convert_instance_tuples_to_lists
      |> stringify
      |> transpose

      {max_name, max_region, max_addr, max_status, max_sto} = columnar
      |> get_maximum_data_length
      |> List.to_tuple

      name_h    = String.ljust("Name",    max_name   - String.length("name"))
      region_h  = String.ljust("Region",  max_region - String.length("region"))
      addr_h    = String.ljust("Address", max_addr   - String.length("address"))
      status_h  = String.ljust("Status",  max_status - String.length("status"))
      storage_h = String.ljust("Storage", max_sto    - String.length("storage"))

      res = ljust_all_entries columnar, {max_name, max_region, max_addr, max_status, max_sto}

      # TODO PRETTY PRINT THE RESULTS
    else
      Mix.Shell.IO.info("There was a problem listing the instances:\n#{res}")
    end
  end

  defp ljust_all_entries([names, regions, addresses, statuses, storages],
                         {mname, mregion, maddress, mstatus, mstorage}) do 
    new_names   = Enum.map(["Name"]    ++ names,     fn x -> ljust(x, mname    - String.length(x)) end)
    new_region  = Enum.map(["Region"]  ++ regions,   fn x -> ljust(x, mregion  - String.length(x)) end)    
    new_addr    = Enum.map(["Address"] ++ addresses, fn x -> ljust(x, maddress - String.length(x)) end)    
    new_status  = Enum.map(["Status"]  ++ statuses,  fn x -> ljust(x, mstatus  - String.length(x)) end)        
    new_storage = Enum.map(["Storage"] ++ storages,  fn x -> ljust(x, mstorage - String.length(x)) end)        

    new_names ++ new_region ++ new_addr ++ new_status ++ new_storage
  end

  defp ljust(str, val), do: String.ljust(str, val)

  defp get_maximum_data_length(instances) do 
    instances
    |> get_maximum_elements_from_each_data_list
    |> Enum.map(&String.length/1)
  end

  defp convert_instance_tuples_to_lists(instances) do
    instances 
    |> Enum.map(fn instance -> Tuple.to_list(instance) end)    
  end

  defp get_maximum_elements_from_each_data_list(data_lists) do 
    data_lists
    |> Enum.map(fn data_list -> 
                 data_list
                 |> Enum.max_by(fn data_elem -> String.length(data_elem) end)
                end)    
  end

  defp transpose([[]|_]), do: []
  defp transpose(rows) do
    [Enum.map(rows, &hd/1) | transpose(Enum.map(rows, &tl/1))]
  end

  defp stringify(rows) do
    Enum.map rows, fn row ->
      Enum.map(row, &to_string/1)
    end
  end    
end