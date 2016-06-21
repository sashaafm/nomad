if Code.ensure_loaded?(GCloudex) do 
  defmodule Nomad.GCL.SQL do

    alias GCloudex.CloudSQL.Client, as: Client
    import Nomad.Utils   

    @behaviour Nomad.SQL

    def list_instances(fun \\ &Client.list_instances/0) do
      case fun.() do
        {:ok, res} ->
          case res.status_code do
            200 ->
              res.body
              |> Poison.decode!
              |> Map.get("items")
              |> parse_list_instances
            _   ->
              show_error_message_and_code(res, :json)
          end
        {:error, reason} ->
          parse_http_error reason
      end
    end

    defp parse_list_instances(nil), do: []
    defp parse_list_instances(items) do 
      items
      |> Enum.map(fn instance -> 
                    {
                      instance["name"], 
                      instance["region"], 
                      if instance["ipAddresses"] != nil do
                        instance["ipAddresses"] 
                        |> List.first 
                        |> Map.get("ipAddress")
                      else
                      "No Address"
                      end,
                      instance["state"],
                      (String.to_integer(instance["maxDiskSize"])) * 10.0e-10                   
                    }
                  end)
    end

    def list_instances!(fun \\ &Client.list_instances/0), do: fun.()

    def get_instance(instance, fun \\ &Client.get_instance/1) do
      case fun.(instance) do 
        {:ok, res} ->
          case res.status_code do 
            200 ->
              res.body
              |> Poison.decode!
              |> parse_get_instance
            _   ->
              show_error_message_and_code(res, :json)
          end
        {:error, reason} ->
          parse_http_error reason
      end
    end

    defp parse_get_instance(res) do 
      {
        res["name"],
        res["region"],
        if res["ipAddresses"] != nil do
          res["ipAddresses"] 
          |> List.first 
          |> Map.get("ipAddress")
        else
          "No Address"
        end,
        res["state"],
        (String.to_integer(res["maxDiskSize"])) * 10.0e-10               
      }
    end

    def get_instance!(instance, fun \\ &Client.get_instance/1), do: fun.(instance)

    # Creates a new instance with name 'instance' in the specified 'tier' and 
    # 'region' and with the provided 'settings'. In the settings the appropriate 
    # network authorization for the current machine will be added. Other desired 
    # authorized networks can be passed through 'addresses'.

    # A new user will also be added with the username 'user' and the 
    # given 'password'.

    # TODO: Receive just the settings map and search through the map for fields that
    # belong to settings, replicaConfiguration or the first level of the request 
    # and arrange them accordingly?

    def insert_instance(instance, settings, {region, tier}, {user, password}, addresses \\ [], fun \\ &Client.insert_instance/4) do 
      addresses           = addresses |> Enum.map(fn ip -> %{"value" => ip} end)
      auth_networks       = Map.new
      |> Map.put("authorizedNetworks", [%{"value" => find_public_ip_address}] ++  addresses)
      |> Map.put("ipv4Enabled", true)
      optional_properties = Map.new |> Map.put(:region, region)
      settings            = Map.put_new(settings, "ipConfiguration", auth_networks)

      case fun.(instance, optional_properties, settings, tier) do 
        {:ok, res} ->
          case res.status_code do
            200 ->
              check_when_instance_is_runnable_and_insert_user(instance, user, password)
            _   ->
              show_error_message_and_code(res, :json)
          end
        {:error, reason} ->
          parse_http_error reason
      end
    end

    ### NEEDS TO BE REVIEWED  PASSWORD NOT USED ###
    def insert_instance!(instance, settings, {region, tier}, {user, password}, addresses \\ [], fun \\ &Client.insert_instance/4) do
      addresses           = addresses |> Enum.map(fn ip -> %{"value" => ip} end)
      auth_networks       = Map.new
      |> Map.put("authorizedNetworks", [%{"value" => find_public_ip_address}] ++  addresses)
      |> Map.put("ipv4Enabled", true)
      optional_properties = Map.new |> Map.put(:region, region)
      settings            = Map.put_new(settings, "ipConfiguration", auth_networks)

      fun.(instance, optional_properties, settings, tier)
    end

    defp check_when_instance_is_runnable_and_insert_user(instance, u, pw) do 
      current = self()
      child   = spawn_link(fn -> send current, {self(), get_instance_state(instance)} end)

      receive do 
        {^child, "RUNNABLE"} -> insert_user_into_instance(instance, u, pw)
      after
        240_000 -> "Timeout while trying to insert the user"
      end
    end

    defp insert_user_into_instance(instance, user, password) do 
      case Client.insert_user(instance, user, password) do 
        {:ok, res} ->
          case res.status_code do
            200 -> :ok
            _   -> "Error trying to insert the user"
          end
        {:error, reason} ->
          reason
      end
    end

    defp get_instance_state(instance) do 
      case Client.get_instance(instance) do 
        {:ok, res} ->
          case res.status_code do 
            200 -> 
              case res.body |> Poison.decode! |> Map.get("state") do 
                "RUNNABLE" -> "RUNNABLE"
                _ -> get_instance_state(instance)
              end

            _ ->
              show_error_message_and_code(res, :json)
          end
        {:error, reason} ->
          reason
      end
    end

    def delete_instance(instance, fun \\ &Client.delete_instance/1) do 
      case fun.(instance) do 
        {:ok, res} ->
          case res.status_code do 
            200 ->
              :ok
            _   ->
              show_error_message_and_code(res, :json)
          end
        {:error, reason} ->
          parse_http_error reason
      end
    end

    def delete_instance!(instance, fun \\ &Client.delete_instance/1), do: fun.(instance)

    def restart_instance(instance, fun \\ &Client.restart_instance/1) do 
      case fun.(instance) do 
        {:ok, res} ->
          case res.status_code do 
            200 ->
              :ok
            _   ->
              show_error_message_and_code(res, :json)
          end
        {:error, reason} ->
          parse_http_error reason
      end
    end

    def restart_instance!(instance, fun \\ &Client.restart_instance/1), do: fun.(instance)

    def list_databases(instance, fun \\ &Client.list_databases/1) do 
      case fun.(instance) do 
        {:ok, res} ->
          case res.status_code do
            200 ->
              res
              |> Map.get(:body)
              |> Poison.decode!
              |> parse_list_databases
            _   ->
              show_error_message_and_code(res, :json)
          end
        {:error, reason} ->
          parse_http_error reason
      end
    end

    def list_databases!(instance, fun \\ &Client.list_databases/1), do: fun.(instance)

    defp parse_list_databases(res) do 
      res["items"]
      |> Enum.map(fn db -> db["name"] end)
    end  

    def list_classes(fun \\ &Client.list_tiers/0) do
      case fun.() do 
        {:ok, res} ->
          case res.status_code do 
            200 ->
              res.body
              |> Poison.decode!
              |> parse_list_classes

            _   ->
              show_error_message_and_code(res, :json)
          end
        {:error, reason} ->
          parse_http_error reason
      end
    end

    defp parse_list_classes(res) do 
      res["items"]
      |> Enum.map(fn tier -> tier["tier"] end)
    end

    def get_instance_address(instance, fun \\ &Client.get_instance/1) do 
      case fun.(instance) do 
        {_, _, address, _, _} -> address
        msg -> msg
      end
    end
  end
end
