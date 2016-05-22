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

        def config_root do
          Application.get_all_env(:my_aws_config_root)
        end

        def list_virtual_machines(fun \\ &describe_instances/0) do
          case fun.() do
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

        def get_virtual_machine(region, instance, fun \\ &list_virtual_machines/0) do
          res = fun.()
          cond do
            is_list(res) ->
              res
              |> Enum.filter(fn {a, b, c, d} = vm -> vm = {instance, b, c, d} end)
              |> List.first
            true -> res
          end
        end

        # The param 'instance' is the id right now, should be allowed to pass name and the
        # funtion should retrieve the id automatically.
        def delete_virtual_machine(region, instance, fun \\ &terminate_instances/1) do
          ids = [instance]
          case fun.(ids) do
            {:ok, res} ->
              case res.status_code do
                200 -> res
                _   -> get_error_message(res)
              end
            {:error, reason} ->
              parse_http_error(reason)
          end
        end

      end
    end
  end
end
