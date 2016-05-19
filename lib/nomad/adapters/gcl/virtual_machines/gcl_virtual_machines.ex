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
                  res |> show_error_message_and_code(:json)
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

################################################################################
######################### TODO: INSERT VIRTUAL MACHINE #########################
################################################################################

        def get_virtual_machine(region, instance, fun \\ &get_instance/3) do 
          fields = "machineType, networkInterfaces, status"
          case fun.(region, instance, fields) do 
            {:ok, res} ->
              case res.status_code do 
                200 ->
                  res.body
                  |> Poison.decode!
                  |> gvm(instance, region)

                _   ->
                  res |> show_error_message_and_code(:json)
              end
            {:error, reason} ->
              parse_http_error reason
          end
        end

        defp gvm(body, instance, region) do
          ip = body["networkInterfaces"] 
          |> List.first 
          |> Map.get("accessConfigs") 
          |> List.first 
          |> Map.get("natIP")

          {instance, body["status"], region, ip}
        end

        def delete_virtual_machine(region, instance, fun \\ &delete_instance/2) do 
          case fun.(region, instance) do 
            {:ok, res} ->
              case res.status_code do 
                200 -> :ok
                _   -> res |> show_error_message_and_code(:json)
              end
            {:error, reason} ->
              parse_http_error reason
          end
        end

        def start_virtual_machine(region, instance, fun \\ &start_instance/2) do 
          case fun.(region, instance) do 
            {:ok, res} ->
              case res.status_code do 
                200 -> :ok
                _   -> res |> show_error_message_and_code(:json)
              end
            {:error, reason} ->
              parse_http_error reason
          end
        end

        def stop_virtual_machine(region, instance, fun \\ &stop_instance/2) do 
          case fun.(region, instance) do 
            {:ok, res} ->
              case res.status_code do
                200 -> :ok
                _   -> res |> show_error_message_and_code(:json)
              end
            {:error, reason} ->
              parse_http_error reason
          end
        end

        def reboot_virtual_machine(region, instance, fun \\ &reset_instance/2) do 
          case fun.(region, instance) do 
            {:ok, res} ->
              case res.status_code do 
                200 -> :ok
                _   -> res |> show_error_message_and_code(:json)
              end
            {:error, reason} ->
              parse_http_error reason
          end
        end

        def set_virtual_machine_class(region, instance, class, fun \\ &set_machine_type/3) do 
          case fun.(region, instance, class) do 
            {:ok, res} ->
              case res.status_code do
                200 -> :ok
                _   -> res |> show_error_message_and_code(:json)
              end
            {:error, reason} ->
              parse_http_error reason
          end
        end

        def list_regions(fun \\ &GCloudex.ComputeEngine.Client.list_regions/1) do
          query_params = %{"fields" => "items/name, items/zones"}
          case fun.(query_params) do 
            {:ok, res} ->
              case res.status_code do
                200 ->
                  res.body
                  |> Poison.decode! 
                  |> Map.get("items") 
                  |> Enum.map(
                    fn map -> 
                      {
                        map["name"], Enum.map(map["zones"], 
                          fn zone -> 
                            zone |> String.split("/") |> List.last
                          end)
                      } 
                    end)
                _   ->
                  res |> show_error_message_and_code
              end
            {:error, reason} ->
              parse_http_error reason
          end
        end

        def list_classes(region, fun \\ &list_machine_types/2) do 
          query_params = %{"fields" => "items/name"}
          case fun.(region, query_params) do
            {:ok , res} -> 
              case res.status_code do 
                200 ->
                  res.body
                  |> Poison.decode! 
                  |> Map.get("items") 
                  |> Enum.map(fn map -> map["name"] end)

                _   -> 
                  res |> show_error_message_and_code              
              end
            {:error, reason} ->
              parse_http_error reason
          end
        end
      end
    end
  end
end