if Code.ensure_loaded?(GCloudex) do 

  defmodule Nomad.GCL.SQL do

    @moduledoc """
    
    """

    defmacro __using__(:gcl) do 
      quote do 
        alias GCloudex.CloudSQL.Client, as: GSQL
        import Nomad.Utils   

        @behaviour NomadSQL        

        def list_instances do
          case GSQL.list_instances do
            {:ok, res} ->
              case res.status_code do
                200 ->
                  res.body
                  |> Poison.decode!
                  |> Map.get("items")
                  |> parse_list_instances
                _   ->
                  res |> show_error_message_and_code
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
        
        def get_instance(instance) do
          case GSQL.get_instance(instance) do 
            {:ok, res} ->
              case res.status_code do 
                200 ->
                  res
                  |> Map.get(:body)
                  |> Poison.decode!
                  |> parse_get_instance
                _   ->
                  res |> show_error_message_and_code
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

        @doc """
        Creates a new instance with name 'instance' in the specified 'tier' and 
        'region' and with the provided 'settings'. In the settings the appropriate 
        network authorization for the current machine will be added. Other desired 
        authorized networks can be passed through 'addresses'.

        A new user will also be added with the username 'user' and the 
        given 'password'.

        TODO: Receive just the settings map and search through the map for fields that
        belong to settings, replicaConfiguration or the first level of the request 
        and arrange them accordingly????
        """
        @spec insert_instance(binary, map, {binary, binary}, {binary, binary}, [binary]) :: :ok | binary
        def insert_instance(instance, settings, {region, tier}, _credentials = {user, password}, addresses \\ []) do 

          addresses = addresses |> Enum.map(fn ip -> %{"value" => ip} end)

          auth_networks = Map.new
          |> Map.put_new("authorizedNetworks", 
              [%{"value" => find_public_ip_address}] ++  addresses)
          |> Map.put_new("ipv4Enabled", true)

          optional_properties = Map.new |> Map.put_new(:region, region)

          settings = Map.put_new(settings, "ipConfiguration", auth_networks)

          case GSQL.insert_instance(instance, optional_properties, settings, tier) do 
            {:ok, res} ->
              case res.status_code do
                200 ->
                  check_when_instance_is_runnable_and_insert_user(instance, user, password)
                _   ->
                  res |> show_error_message_and_code
              end
            {:error, reason} ->
              parse_http_error reason
          end
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
          case GSQL.insert_user(instance, user, password) do 
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
          case GSQL.get_instance(instance) do 
            {:ok, res} ->
              case res.status_code do 
                200 -> 
                  case res.body |> Poison.decode! |> Map.get("state") do 
                    "RUNNABLE" -> "RUNNABLE"
                    _ -> get_instance_state(instance)
                  end
                  
                _ ->
                  res |> show_error_message_and_code
              end
            {:error, reason} ->
              reason
          end
        end

        @doc """
        Deletes the given 'instance'.
        """
        @spec delete_instance(binary) :: :ok | binary
        def delete_instance(instance) do 
          case GSQL.delete_instance(instance) do 
            {:ok, res} ->
              case res.status_code do 
                200 ->
                  :ok
                _   ->
                  res |> show_error_message_and_code
              end
            {:error, reason} ->
              parse_http_error reason
          end
        end

        @doc """
        Restarts the given 'instance'.
        """
        @spec restart_instance(binary) :: :ok | binary
        def restart_instance(instance) do 
          case GSQL.restart_instance(instance) do 
            {:ok, res} ->
              case res.status_code do 
                200 ->
                  :ok
                _   ->
                  res |> show_error_message_and_code
              end
            {:error, reason} ->
              parse_http_error reason
          end
        end

        @doc """
        Lists all the databases belonging to the given 'instance'.
        """
        @spec list_databases(binary) :: list(binary)
        def list_databases(instance) do 
          case GSQL.list_databases(instance) do 
            {:ok, res} ->
              case res.status_code do
                200 ->
                  res
                  |> Map.get(:body)
                  |> Poison.decode!
                  |> parse_list_databases
                _   ->
                  res |> show_error_message_and_code
              end
            {:error, reason} ->
              parse_http_error reason
          end
        end

        defp parse_list_databases(res) do 
          res["items"]
          |> Enum.map(fn db -> db["name"] end)
        end  

        @doc """
        Lists all the available instance tiers to choose from.
        """
        @spec list_classes :: list(binary) | binary
        def list_classes do
          case GSQL.list_tiers do 
            {:ok, res} ->
              case res.status_code do 
                200 ->
                  res.body
                  |> Poison.decode!
                  |> parse_list_classes

                _   ->
                  res |> show_error_message_and_code
              end
            {:error, reason} ->
              parse_http_error reason
          end
        end

        defp parse_list_classes(res) do 
          res["items"]
          |> Enum.map(fn tier -> tier["tier"] end)
        end

        @doc """
        Returns the given 'instance' address.
        """
        @spec get_instance_address(binary) :: binary
        def get_instance_address(instance) do 
          case get_instance(instance) do 
            {_, _, address, _, _} -> address
            msg -> msg
          end
        end
      end
    end
  end
end