if Code.ensure_loaded?(GCloudex) do
  defmodule Nomad.GCL.VirtualMachines do
    import GCloudex.ComputeEngine.Client
    import Nomad.Utils

    @moduledoc """
    Google Compute Engine adapter for Nomad. API interaction is done through
    GCloudex.
    """

    @behaviour NomadVirtualMachines

    ########################
    ### Virtual Machines ###
    ########################

    def list_virtual_machines(region, fun \\ &list_instances/2) do
      query = %{"fields" => "items"}
      case fun.(region, query) do
        {:ok, res} ->
          case res.status_code do
            200 ->
              res.body
              |> Poison.decode!
              |> Map.get("items")
              |> check_for_nil(&get_vm_data/1)

            _   ->
              show_error_message_and_code(res, :json)
          end
        {:error, reason} ->
          parse_http_error(reason)
      end
    end

    def list_virtual_machines!(region, fun \\ &list_instances/2), do: fun.(region, %{"fields" => "items"})

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

    def create_virtual_machine(region, class, image, auto_delete, fun \\ &insert_instance/2) do
      epoch    = :calendar.universal_time |> :calendar.datetime_to_gregorian_seconds
      name     = "instance-#{epoch}"
      resource = %{
        "name"        => name,
        "machineType" => "zones/#{region}/machineTypes/#{class}",
        "disks" => [
          %{
            "autoDelete"       => auto_delete,
            "boot"             => true,
            "type"             => "PERSISTENT",
            "initializeParams" => %{
              "sourceImage" => image
            }
          }
        ],
        "networkInterfaces" => [
          %{
            "accessConfigs" => [
            %{
              "name" => "External NAT",
              "type" => "ONE_TO_ONE_NAT"
            }
          ],
            "network" => "global/networks/default"
          }
        ]
      }

      case fun.(region, resource) do
        {:ok, res} ->
          case res.status_code do
            200 -> :ok
            _   -> show_error_message_and_code(res, :json)
          end
        {:error, reason} ->
          parse_http_error(reason)
      end
    end

    def create_virtual_machine!(region, class, image, auto_delete, fun \\ &insert_instance/2) do
      epoch    = :calendar.universal_time |> :calendar.datetime_to_gregorian_seconds
      name     = "instance-#{epoch}"
      resource = %{
        "name"        => name,
        "machineType" => "zones/#{region}/machineTypes/#{class}",
        "disks" => [
          %{
            "autoDelete"       => auto_delete,
            "boot"             => true,
            "type"             => "PERSISTENT",
            "initializeParams" => %{
              "sourceImage" => image
            }
          }
        ],
        "networkInterfaces" => [
          %{
            "accessConfigs" => [
            %{
              "name" => "External NAT",
              "type" => "ONE_TO_ONE_NAT"
            }
          ],
            "network" => "global/networks/default"
          }
        ]
      }

      fun.(region, resource)
    end

    def get_virtual_machine(region, instance, fun \\ &get_instance/3) do
      fields = "machineType, networkInterfaces, status"
      case fun.(region, instance, fields) do
        {:ok, res} ->
          case res.status_code do
            200 ->
              res.body
              |> Poison.decode!
              |> gvm(instance)

            _   ->
              show_error_message_and_code(res, :json)
          end
        {:error, reason} ->
          parse_http_error(reason)
      end
    end

    def get_virtual_machine!(region, instance, fun \\ &get_instance/3), do: fun.(region, instance, "machineType, networkInterfaces, status")

    defp gvm(body, instance) do
      ip = body["networkInterfaces"]
      |> List.first
      |> Map.get("accessConfigs")
      |> List.first
      |> Map.get("natIP")

      {instance, body["status"], body["machineType"] |> String.split("/") |> List.last, ip}
    end

    def delete_virtual_machine(region, instance, fun \\ &delete_instance/2) do
      case fun.(region, instance) do
        {:ok, res} ->
          case res.status_code do
            200 -> :ok
            _   -> show_error_message_and_code(res, :json)
          end
        {:error, reason} ->
          parse_http_error(reason)
      end
    end

    def delete_virtual_machine!(region, instance, fun \\ &delete_instance/2), do: fun.(region, instance)

    def start_virtual_machine(region, instance, fun \\ &start_instance/2) do
      case fun.(region, instance) do
        {:ok, res} ->
          case res.status_code do
            200 -> :ok
            _   -> show_error_message_and_code(res, :json)
          end
        {:error, reason} ->
          parse_http_error(reason)
      end
    end

    def start_virtual_machine!(region, instance, fun \\ &start_instance/2), do: fun.(region, instance)

    def stop_virtual_machine(region, instance, fun \\ &stop_instance/2) do
      case fun.(region, instance) do
        {:ok, res} ->
          case res.status_code do
            200 -> :ok
            _   -> show_error_message_and_code(res, :json)
          end
        {:error, reason} ->
          parse_http_error(reason)
      end
    end

    def stop_virtual_machine!(region, instance, fun \\ &stop_instance/2), do: fun.(region, instance)

    def reboot_virtual_machine(region, instance, fun \\ &reset_instance/2) do
      case fun.(region, instance) do
        {:ok, res} ->
          case res.status_code do
            200 -> :ok
            _   -> show_error_message_and_code(res, :json)
          end
        {:error, reason} ->
          parse_http_error(reason)
      end
    end

    def reboot_virtual_machine!(region, instance, fun \\ &reset_instance/2), do: fun.(region, instance)

    def set_virtual_machine_class(region, instance, class, fun \\ &set_machine_type/3) do
      case fun.(region, instance, class) do
        {:ok, res} ->
          case res.status_code do
            200 -> :ok
            _   -> show_error_message_and_code(res, :json)
          end
        {:error, reason} ->
          parse_http_error(reason)
      end
    end

    def set_virtual_machine_class!(region, instance, class, fun \\ &set_machine_type/3), do: fun.(region, instance, class) 

    #############
    ### Disks ###
    #############

    def list_disks(region, fun \\ &GCloudex.ComputeEngine.Client.list_disks/2) do
      query_params = %{"fields" => "items(name,sizeGb,sourceImage,status,type)"}
      case fun.(region, query_params) do
        {:ok, res} ->
          case res.status_code do
            200 ->
              res.body
              |> Poison.decode!
              |> Map.get("items")
              |> check_for_nil(&ld/1)
            _   ->
              show_error_message_and_code(res, :json)
          end
        {:error, reason} ->
          parse_http_error(reason)
      end
    end

    def list_disks!(region, fun \\ &GCloudex.ComputeEngine.Client.list_disks/2), do: fun.(region, %{"fields" => "items(name,sizeGb,sourceImage,status,type)"})

    defp ld(item) do
      image = item["sourceImage"] |> String.split("/") |> List.last
      type  = item["type"] |> String.split("/") |> List.last
      {item["name"], item["sizeGb"], image, item["status"], type}
    end

    def get_disk(region, disk, fun \\ &GCloudex.ComputeEngine.Client.get_disk/3) do
      fields = "name,sizeGb,sourceImage,status,type"
      case fun.(region, disk, fields) do
        {:ok, res} ->
          case res.status_code do
            200 ->
              res.body
              |> Poison.decode!
              |> gd

            _   ->
              show_error_message_and_code(res, :json)
          end
        {:error, reason} ->
          parse_http_error(reason)
      end
    end

    def get_disk!(region, disk, fun \\ &GCloudex.ComputeEngine.Client.get_disk/3), do: fun.(region, disk, "name,sizeGb,sourceImage,status,type")

    defp gd(disk) do
      image = disk["sourceImage"] |> String.split("/") |> List.last
      type  = disk["type"] |> String.split("/") |> List.last

      {disk["name"], disk["sizeGb"], image, disk["status"], type}
    end

    def create_disk(region, size), do: cd region, size

    def create_disk(region, size, image), do: cd_with_img region, size, image

    def create_disk!(region, size), do: cd! region, size

    def create_disk!(region, size, image), do: cd_with_img! region, size, image

    defp cd(region, size, fun \\ &GCloudex.ComputeEngine.Client.insert_disk/2) do
      epoch    = :calendar.universal_time |> :calendar.datetime_to_gregorian_seconds
      name     = "disk-#{epoch}"
      resource = %{"name" => name, "sizeGb" => size}

      case fun.(region, resource) do
        {:ok, res} ->
          case res.status_code do
            200 -> :ok
            _   -> show_error_message_and_code(res, :json)
          end
        {:error, reason} ->
          parse_http_error(reason)
      end
    end

    defp cd!(region, size, fun \\ &GCloudex.ComputeEngine.Client.insert_disk/2) do
      epoch    = :calendar.universal_time |> :calendar.datetime_to_gregorian_seconds
      name     = "disk-#{epoch}"
      resource = %{"name" => name, "sizeGb" => size}

      fun.(region, resource)
    end

    defp cd_with_img(region, size, image, fun \\ &GCloudex.ComputeEngine.Client.insert_disk/3) do
      epoch    = :calendar.universal_time |> :calendar.datetime_to_gregorian_seconds
      name     = "disk-#{epoch}"
      resource = %{"name" => name, "sizeGb" => size}

      case fun.(region, resource, image) do
        {:ok, res} ->
          case res.status_code do
            200 -> :ok
            _   ->
              show_error_message_and_code(res, :json)
          end
        {:error, reason} ->
          parse_http_error(reason)
      end
    end

    defp cd_with_img!(region, size, image, fun \\ &GCloudex.ComputeEngine.Client.insert_disk/3) do
      epoch    = :calendar.universal_time |> :calendar.datetime_to_gregorian_seconds
      name     = "disk-#{epoch}"
      resource = %{"name" => name, "sizeGb" => size}

      fun.(region, resource, image)
    end

    def delete_disk(region, disk, fun \\ &GCloudex.ComputeEngine.Client.delete_disk/2) do
      case fun.(region, disk) do
        {:ok, res} ->
          case res.status_code do
            200 -> :ok
            _   -> show_error_message_and_code(res, :json)
          end
        {:error, reason} ->
          parse_http_error(reason)
      end
    end

    def delete_disk!(region, disk, fun \\ &GCloudex.ComputeEngine.Client.delete_disk/2), do: fun.(region, disk)

    def attach_disk(region, instance, disk, device_name, fun \\ &GCloudex.ComputeEngine.Client.attach_disk/3) do
      source   = get_disk_self_link(region, disk)
      resource = %{"source" => source, "deviceName" => device_name}
      case fun.(region, instance, resource) do
        {:ok, res} ->
          case res.status_code do
            200 -> :ok
            _   -> show_error_message_and_code(res, :json)
          end
        {:error, reason} ->
          parse_http_error(reason)
      end
    end

    def attach_disk!(region, instance, disk, device_name, fun \\ &GCloudex.ComputeEngine.Client.attach_disk/3) do
      source   = get_disk_self_link(region, disk)
      resource = %{"source" => source, "deviceName" => device_name}

      fun.(region, instance, resource)
    end

    def detach_disk(region, instance, disk, fun \\ &GCloudex.ComputeEngine.Client.detach_disk/3) do
      case fun.(region, instance, disk) do
        {:ok, res} ->
          case res.status_code do
            200 -> :ok
            _   -> show_error_message_and_code(res, :json)
          end
        {:error, reason} ->
          parse_http_error(reason)
      end
    end

    def detach_disk!(region, instance, disk, fun \\ &GCloudex.ComputeEngine.Client.detach_disk/3), do: fun.(region, instance, disk)

    ##############
    ### Others ###
    ##############

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
                fn map -> map["name"] end)
            _   ->
              show_error_message_and_code(res, :json)
          end
        {:error, reason} ->
          parse_http_error(reason)
      end
    end

    def list_regions!(fun \\ &GCloudex.ComputeEngine.Client.list_regions/1), do: fun.(%{"fields" => "items/name, items/zones"})

    def list_classes(fun \\ &lc/1) do
      list = lr 
      |> Enum.map(fn {_a, b} -> b end)
      |> List.flatten

      list
      |> Enum.map(fn x -> lc(x) end)
      |> List.flatten
      |> Enum.uniq
    end

    defp lr(fun \\ &GCloudex.ComputeEngine.Client.list_regions/1) do
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
                    map["name"], 
                    Enum.map(
                      map["zones"], 
                      fn z -> 
                        z |> String.split("/") |> List.last 
                      end) 
                  }
                end)
            _   ->
              show_error_message_and_code(res, :json)
          end
        {:error, reason} ->
          parse_http_error(reason)
      end
    end

    defp lc(region, fun \\ &list_machine_types/2) do
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
              show_error_message_and_code(res, :json)
          end
        {:error, reason} ->
          parse_http_error(reason)
      end
    end

    ###############
    ### Helpers ###
    ###############

    defp check_for_nil(key, fun) do
      case key do
        nil -> []
        _   -> Enum.map(key, fn x -> fun.(x) end)
      end
    end

    defp get_disk_self_link(region, disk, fun \\ &GCloudex.ComputeEngine.Client.get_disk/3) do
      fields = "selfLink"
      case fun.(region, disk, fields) do
        {:ok, res} ->
          case res.status_code do
            200 ->
              res.body
              |> Poison.decode!
              |> Map.get("selfLink")
            _   ->
              show_error_message_and_code(res, :json)
          end
        {:error, reason} ->
          parse_http_error(reason)
      end
    end
  end
end
