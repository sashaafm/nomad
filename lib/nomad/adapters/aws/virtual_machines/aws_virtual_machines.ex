if Code.ensure_loaded?(ExAws) do

  defmodule Nomad.AWS.VirtualMachines do

    @moduledoc """
    Amazon Elastic Compute Cloud adapter for Nomad. API interaction is done
    through Ex_Aws.
    """

    defmacro __using__(:aws) do
      quote do
        use ExAws.EC2.Client
        import Nomad.Utils

        @behaviour NomadVirtualMachines

        def config_root do
          Application.get_all_env(:my_aws_config_root)
        end

        def list_virtual_machines(region, fun \\ &ExAws.EC2.Impl.describe_instances/1) do
          case fun.(ExAws.EC2.new(region: region)) do
            {:ok, res} ->
              case res.status_code do
                200 ->
                  res.body
                  |> get_vm_data
                _   ->
                  get_error_message(res)
              end
            {:error, reason} ->
              parse_http_error reason
          end
        end

        defp get_vm_data(data) do
          name   = data |> Friendly.find("value")        |> Enum.map(fn name -> name.text end)
          status = data |> Friendly.find("name")         |> Enum.map(fn status -> status.text end)
          ip     = data |> Friendly.find("publicip")     |> Enum.map(fn ip -> ip.text end)
          class  = data |> Friendly.find("instancetype") |> Enum.map(fn class -> class.text end)

          List.zip([name, status, ip, class])
        end

        def get_virtual_machine(region, instance, fun \\ &list_virtual_machines/1) do
          res = fun.(region)
          cond do
            is_list(res) ->
              res
              |> Enum.filter(fn {a, b, c, d} = vm -> vm == {instance, b, c, d} end)
              |> List.first
            true -> res
          end
        end

        def create_virtual_machine(zone, class, image, auto_delete, fun \\ &ExAws.EC2.Impl.run_instances/5) do
          auto_delete = if auto_delete == true do "terminate" else "stop" end
          opts        = [
            "InstanceType":                      class,
            "InstanceInitiatedShutdownBehavior": auto_delete,
            "Placement.AvailabilityZone":        zone
          ]
          case fun.(ExAws.EC2.new(region: get_region_from_zone(zone)), image, 1, 1, opts) do
            {:ok, res} ->
              case res.status_code do
                200 -> :ok
                _   -> get_error_message(res)
              end
            {:error, reason} ->
              parse_http_error(reason)
          end
        end

        defp get_region_from_zone(zone) do
          list_regions
          |> Enum.filter(fn region -> String.contains?(zone, region) end)
          |> List.first
        end

        # The param 'instance' is the id right now, should be allowed to pass name and the
        # funtion should retrieve the id automatically.
        def delete_virtual_machine(region, instance, fun \\ &ExAws.EC2.Impl.terminate_instances/2) do
          ids = [get_instance_id_from_name(region, instance)]
          case fun.(ExAws.EC2.new(region: region), ids) do
            {:ok, res} ->
              case res.status_code do
                200 -> :ok
                _   -> get_error_message(res)
              end
            {:error, reason} ->
              parse_http_error(reason)
          end
        end

        def start_virtual_machine(region, instance, fun \\ &ExAws.EC2.Impl.start_instances/2) do
          ids = [get_instance_id_from_name(region, instance)]
          case fun.(ExAws.EC2.new(region: region), ids) do
            {:ok, res} ->
              case res.status_code do
                200 -> :ok
                _   -> get_error_message(res)
              end
            {:error, reason} ->
              parse_http_error(reason)
          end
        end

        def stop_virtual_machine(region, instance, fun \\ &ExAws.EC2.Impl.stop_instances/2) do
          ids = [get_instance_id_from_name(region, instance)]
          case fun.(ExAws.EC2.new(region: region), ids) do
            {:ok, res} ->
              case res.status_code do
                200 -> :ok
                _   -> get_error_message(res)
              end
            {:error, reason} ->
              parse_http_error(reason)
          end
        end

        def reboot_virtual_machine(region, instance, fun \\ &ExAws.EC2.Impl.reboot_instances/2) do
          ids = [get_instance_id_from_name(region, instance)]
          case fun.(ExAws.EC2.new(region: region), ids) do
            {:ok, res} ->
              case res.status_code do
                200 -> :ok
                _   -> get_error_message(res)
              end
            {:error, reason} ->
              parse_http_error(reason)
          end
        end

        def set_virtual_machine_class(region, instance, class, fun \\ &ExAws.EC2.Impl.modify_instance_attribute/3) do
          id   = get_instance_id_from_name(region, instance)
          opts = ["InstanceType.Value": class]

          case fun.(ExAws.EC2.new(region: region), id, opts) do
            {:ok, res} ->
              case res.status_code do
                200 -> :ok
                _   -> get_error_message(res)
              end
            {:error, reason} ->
              parse_http_error(reason)
          end
        end

        #############
        ### Disks ###
        #############

        def list_disks(region, fun \\ &ExAws.EC2.Impl.describe_volumes/1) do
          case fun.(ExAws.EC2.new(region: region)) do
            {:ok, res} ->
              case res.status_code do
                200 ->
                  res.body
                  |> ld
                _   ->
                  get_error_message(res)
              end
            {:error, reason} ->
              parse_http_error(reason)
          end
        end

        defp ld(disk) do
          names  = disk |> Friendly.find("volumeid")   |> Enum.map(fn a -> a.text end) |> Enum.uniq
          sizes  = disk |> Friendly.find("size")       |> Enum.map(fn a -> a.text end)
          images = disk |> Friendly.find("snapshotid") |> Enum.map(fn a -> a.text end)
          status = disk |> Friendly.find("status")     |> Enum.map(fn a -> a.text end) |> Enum.filter(fn a -> a != "attached" end)
          type   = disk |> Friendly.find("volumetype") |> Enum.map(fn a -> a.text end)

          List.zip [names, sizes, images, status, type]
        end

        def get_disk(region, disk, fun \\ &list_disks/1) do
          res = fun.(region)

          cond do
            is_list(res) ->
              [vol] = res
              |> Enum.filter(fn {a, b, c, d, e} = vol -> a == disk end)

              vol
            true ->
              res
          end
        end

        def create_disk(zone, size) when is_integer(size) do
          cd zone, size
        end

        def create_disk(zone, size, image) when is_integer(size) do
          cd_with_img zone, size, image
        end

        defp cd(region, size, fun \\ &create_volume/2) do
          case fun.(region, size) do
            {:ok, res} ->
              case res.status_code do
                200 -> :ok
                _   -> get_error_message(res)
              end
            {:error, reason} ->
              parse_http_error(reason)
          end
        end

        defp cd_with_img(region, size, image, fun \\ &create_volume/3) do
          opts = ["SnapshotId": image]
          case fun.(region, size, opts) do
            {:ok, res} ->
              case res.status_code do
                200 -> :ok
                _   -> get_error_message(res)
              end
            {:error, reason} ->
              parse_http_error(reason)
          end

        end

        def delete_disk(region, disk, fun \\ &ExAws.EC2.Impl.delete_volume/2) do
          vol =
            if not String.contains?(disk, "vol-") do
              get_volume_id_from_name(region, disk)
            else
              disk
            end

          case fun.(ExAws.EC2.new(region: region), vol) do
            {:ok, res} ->
              case res.status_code do
                200 -> :ok
                _   -> get_error_message(res)
              end
            {:error, reason} ->
              parse_http_error(reason)
          end
        end

        def attach_disk(region, instance, disk, device_name, fun \\ &ExAws.EC2.Impl.attach_volume/4) do
          vol =
          if not String.contains?(disk, "vol-") do
            get_volume_id_from_name(region, disk)
          else
            disk
          end
          instance =
          if not String.contains?(instance, "i-") do
            get_instance_id_from_name(region, instance)
          else
            instance
          end

          case fun.(ExAws.EC2.new(region: region), instance, disk, device_name) do
            {:ok, res} ->
              case res.status_code do
                200 -> :ok
                _   -> get_error_message(res)
              end
            {:error, reason} ->
              parse_http_error(reason)
          end
        end

        def detach_disk(region, instance, disk, fun \\ &ExAws.EC2.Impl.detach_volume/3) do
          vol =
            if not String.contains?(disk, "vol-") do
              get_volume_id_from_name(region, disk)
            else
              disk
            end
          instance =
            if not String.contains?(instance, "i-") do
              get_instance_id_from_name(region, instance)
            else
              instance
            end

          opts = ["InstanceId": instance]
          case fun.(ExAws.EC2.new(region: region), vol, opts) do
            {:ok, res} ->
              case res.status_code do
                200 -> :ok
                _   -> get_error_message(res)
              end
            {:error, reason} ->
              parse_http_error(reason)
          end
        end

        ##############
        ### Others ###
        ##############

        def list_regions(fun \\ &describe_regions/0) do
          case fun.() do
            {:ok, res} ->
              case res.status_code do
                200 ->
                  res.body
                  |> Friendly.find("regionname")
                  |> Enum.map(fn region -> region.text end)
                _   ->
                  get_error_message(res)
              end
            {:error, reason} ->
              parse_http_error(reason)
          end
        end

        def list_classes(fun \\ &lc/0) do
          fun.()
        end

        defp lc do
          [
            "t2.nano", "t2.micro", "t2.small", "t2.medium", "t2.large",
            "m4.large", "m4.xlarge", "m4.2xlarge", "m4.4xlarge", "m4.10xlarge",
            "m3.medium", "m3.large", "m3.xlarge", "m3.2xlarge",
            "c4.large", "c4.xlarge", "c4.2xlarge", "c4.4xlarge", "c4.8xlarge",
            "c3.large", "c3.xlarge", "c3.2xlarge", "c3.4xlarge", "c3.8xlarge",
            "x1.32xlarge",
            "r3.large", "r3.xlarge", "r3.2xlarge", "r3.4xlarge", "r3.8xlarge",
            "g2.2xlarge", "g2.8xlarge",
            "i2.xlarge", "i2.2xlarge", "i2.4xlarge", "i2.8xlarge",
            "d2.xlarge", "d2.2xlarge", "d2.4xlarge", "d2.8xlarge",
          ]
        end

        ###############
        ### Helpers ###
        ###############

        # REVIEW THIS FUNCTION
        defp get_instance_id_from_name(instance) do
          case describe_instances do
            {:ok, res} ->
              case res.status_code do
                200 ->
                  {_, id} = res.body
                  |> get_name_and_id(:instance)
                  |> Enum.filter(fn {a, b} -> a == instance end)
                  |> List.first

                  id
                _   ->
                  get_error_message(res)
              end
            {:error, reason} ->
              parse_http_error reason
          end
        end

        defp get_instance_id_from_name(region, instance) do
          case ExAws.EC2.new(region: region) |> ExAws.EC2.Impl.describe_instances do
            {:ok, res} ->
              case res.status_code do
                200 ->
                  {_, id} = res.body
                  |> get_name_and_id(:instance)
                  |> Enum.filter(fn {a, b} -> a == instance end)
                  |> List.first

                  id
                _   ->
                  get_error_message(res)
              end
            {:error, reason} ->
              parse_http_error reason
          end
        end

        defp get_volume_id_from_name(name) do
          case describe_volumes do
            {:ok, res} ->
              case res.status_code do
                200 ->
                  [{_, id}] = res.body
                  |> get_name_and_id(:volume)
                  |> Enum.filter(fn {a, b} -> a == name end)

                  id
                _   ->
                  get_error_message(res)
              end
            {:error, reason} ->
              parse_http_error(reason)
          end
        end

        defp get_volume_id_from_name(region, name) do
          case ExAws.EC2.new(region: region) |> ExAws.EC2.Impl.describe_volumes do
            {:ok, res} ->
              case res.status_code do
                200 ->
                  [{_, id}] = res.body
                  |> get_name_and_id(:volume)
                  |> Enum.filter(fn {a, b} -> a == name end)

                  id
                _   ->
                  get_error_message(res)
              end
            {:error, reason} ->
              parse_http_error(reason)
          end
        end

        defp get_name_and_id(body, :instance) do
          name = body |> Friendly.find("value")      |> Enum.map(fn a -> a.text end)
          id   = body |> Friendly.find("instanceid") |> Enum.map(fn a -> a.text end)

          List.zip([name, id])
        end
        defp get_name_and_id(body, :volume) do
          name = body |> Friendly.find("value")    |> Enum.map(fn a -> a.text end)
          id   = body |> Friendly.find("volumeid") |> Enum.map(fn a -> a.text end) |> Enum.uniq

          List.zip([name, id])
        end
      end
    end
  end
end
