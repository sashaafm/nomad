if Code.ensure_loaded?(GCloudex) do 
  defmodule Nomad.GCL.VirtualMachines do

    @moduledoc """
    Google Compute Engine adapter for Nomad. API interaction is done through
    GCloudex.
    """

    defmacro __using__(:gcl) do 
      quote do 
        import GCloudex.ComputeEngine.Client
        import Nomad.Utils

        def list_virtual_machines(region, fun \\ &list_instances/2) do 
          query = %{"fields" => "items"}
          case fun.(region, query) do
            {:ok, res} ->
              case res.status_code do 
                200 -> 
                  res.body
                  |> Poison.decode!
                  |> Map.get("items")
                  |> Enum.map(fn vm -> get_vm_data(vm) end)
                _   ->
                  res |> show_error_message_and_code
              end
            {:error, reason} ->
              parse_http_error reason
          end
        end

        defp get_vm_data(vm) do 
          ip = vm["networkInterfaces"] 
          |> List.first 
          |> Map.get("accessConfigs") 
          |> List.first 
          |> Map.get("natIP")

          {
            vm["name"], 
            vm["status"], 
            vm["machineType"] |> String.split("/") |> List.last,
            if ip != nil do ip else "No Address" end
          }
        end

      end
    end
  end
end