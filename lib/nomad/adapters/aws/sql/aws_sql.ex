if Code.ensure_loaded?(ExAws) do 

  defmodule Nomad.AWS.SQL do

    @moduledoc """
    Amazon Relational Database Service adapter for Nomad. API interaction is done
    through Ex_AWS.
    """

    defmacro __using__(:aws) do 
      quote do
        use ExAws.RDS.Client
        import Nomad.Utils

        @behaviour NomadSQL

        def config_root do 
          Application.get_all_env(:my_aws_config_root)
        end  

        @doc """
        Lists all Amazon RDS instances for the provided credentials alongside their
        region and address.
        """
        @spec list_instances :: list(tuple) | binary
        def list_instances do 
          case describe_db_instances do 
            {:ok, res} ->
              case res.status_code do 
                200 ->
                  ids = res.body
                  |> Friendly.find("dbinstanceidentifier")

                  zones = res.body
                  |> Friendly.find("availabilityzone")

                  addresses = res.body
                  |> Friendly.find("address")

                  status = res.body
                  |> Friendly.find("status")

                  storage = res.body
                  |> Friendly.find("allocatedstorage")

                  parse_list_instances ids, zones, addresses, status, storage
                _   ->
                  get_error_message res
              end
            {:error, reason} ->
              show_message_and_error_code reason
          end
        end

        defp parse_list_instances(ids, zones, addresses, status, storage) do 
          ids_list = ids
          |> Enum.map(fn x -> x.text end)

          zones_list = zones
          |> Enum.map(fn x -> x.text end)

          addresses_list = addresses
          |> Enum.map(fn x -> x.text end)

          status_list = status
          |> Enum.map(fn x -> x.text end)

          storage_list = storage
          |> Enum.map(fn x -> x.text end)        

          List.zip [ids_list] ++ [zones_list] ++ [addresses_list] ++ 
            [status_list] ++ [storage_list]
        end

        @doc """
        Retrieves the name, region and address of the given 'instance'.
        """
        def get_instance(instance) do 
          case describe_db_instances(%{"DBInstanceIdentifier" => instance}) do 
            {:ok, res} ->
              case res.status_code do 
                200 ->
                  name = res.body
                  |> Friendly.find("dbinstanceidentifier")
                  |> List.first
                  |> Map.get(:text)

                  region = res.body
                  |> Friendly.find("availabilityzone")
                  |> List.first
                  |> Map.get(:text)            

                  address = res.body
                  |> Friendly.find("address")
                  |> List.first
                  |> Map.get(:text)

                  status = res.body
                  |> Friendly.find("status")
                  |> List.first            
                  |> Map.get(:text)

                  storage = res.body
                  |> Friendly.find("allocatedstorage")
                  |> List.first
                  |> Map.get(:text)

                  {name, region, address, status, storage}
                _   ->
                  get_error_message res
              end
            {:error, reason} ->
              show_message_and_error_code reason
          end
        end

        @doc """
        Creates a new instance with the name 'instance' and user 'username' with 
        password 'password' and the allocated storage size of 'storage' using the 
        provided SQL 'engine'. The instance has the class 'class'.

        The settings must be passed as a Map in the format %{key: value}. This map may
        have additional query parameters besides the required ones in the function
        definition.

        TODO: A Security Group must be created to be added with the list of addresses.
        This can only be done when the EC2 API is ready.
        """
        @spec insert_instance(binary, map, binary, {binary, binary}, [binary]) :: :ok | binary
        def insert_instance(instance, settings, class, _credentials = {username, password}, addresses) do 
          storage = settings.storage
          engine  = settings.engine

          case create_db_instance(instance, username, password, storage, class, engine, settings) do 
            {:ok, res} ->
              case res.status_code do 
                200 ->
                  :ok
                _   ->
                  get_error_message res
              end
            {:error, reason} ->
              show_message_and_error_code reason
          end
        end

        @doc """
        Deletes the given 'instance'.
        """
        @spec delete_instance(binary) :: :ok | binary
        def delete_instance(instance) do 
          case delete_db_instance(instance) do 
            {:ok, res} ->
              case res.status_code do 
                200 ->
                  :ok
                _   ->
                  get_error_message res
              end
            {:error, reason} ->
              show_message_and_error_code reason
          end
        end

        @doc """
        Restarts the given instance.
        """
        @spec restart_instance(binary) :: :ok | binary
        def restart_instance(instance) do
          case reboot_db_instance(instance) do 
            {:ok, res} ->
              case res.status_code do 
                200 ->
                  :ok
                _   ->
                  get_error_message res
              end
            {:error, reason} ->
              show_message_and_error_code reason
          end
        end

        @doc """
        Lists all databases for the given 'instance'.
        """
        @spec list_databases(binary) :: list(binary) | binary
        def list_databases(instance) do 
          case describe_db_instances(%{"DBInstanceIdentifier" => instance}) do 
            {:ok, res} ->
              case res.status_code do
                200 ->
                  res.body
                  |> Friendly.find("dbname")
                  |> Enum.map(fn map -> map.text end)
                _   ->
                  get_error_message res
              end
            {:error, reason} ->
              show_message_and_error_code reason
          end
        end

        @doc """
        Lists all the available instance classes.
        """
        @spec list_classes() :: list(binary)
        def list_classes do
          ["db.t1.micro",    "db.m1.small",   "db.m1.medium",  "db.m1.large", 
           "db.m1.xlarge",   "db.m2.xlarge",  "db.m2.2xlarge", "db.m2.4xlarge", 
           "db.m3.medium",   "db.m3.large",   "db.m3.xlarge",  "db.m3.2xlarge",
           "db.m4.large",    "db.m4.xlarge",  "db.m4.2xlarge", "db.m4.4xlarge",
           "db.m4.10xlarge", "db.r3.large",   "db.r3.xlarge",  "db.r3.2xlarge", 
           "db.r3.4xlarge",  "db.r3.8xlarge", "db.t2.micro",   "db.t2.small",
           "db.t2.medium",   "db.t2.large"]
        end

        @doc """
        Returns the address for the given 'instance'.
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