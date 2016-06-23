if Code.ensure_loaded?(ExAws) do 
  defmodule Nomad.AWS.SQL do
    use ExAws.RDS.Client
    import Nomad.Utils
    alias Nomad.AWS.SQL.Helper, as: Helper

    @behaviour Nomad.SQL

    def config_root do 
      Application.get_all_env(:my_aws_config_root)
    end  

    def list_instances(fun \\ &ExAws.RDS.Impl.describe_db_instances/1) do 
      result = 
        for region <- Helper.get_regions do
          case fun.(ExAws.RDS.new(region: region)) do 
            {:ok, res} ->
                case res.status_code do 
                  200 ->
                  ids       = res.body |> Friendly.find("dbinstanceidentifier")
                  zones     = res.body |> Friendly.find("availabilityzone")
                  addresses = res.body |> Friendly.find("address")
                  status    = res.body |> Friendly.find("dbinstancestatus")
                  storage   = res.body |> Friendly.find("allocatedstorage")
            
                  parse_list_instances ids, zones, addresses, status, storage
              _   ->
                    get_error_message res
                end
            {:error, reason} ->
              parse_http_error reason
          end
        end
        |> List.flatten

      if Enum.any?(result, fn x -> is_binary(x) end) do
        Enum.find(result, fn x -> is_binary(x) end)
      else
        result
      end
    end

    def list_instances!(fun \\ &describe_db_instances/0), do: fun.()

    defp parse_list_instances(ids, zones, addresses, status, storage) do 
      ids_list       = ids       |> Enum.map(fn x -> x.text end)
      zones_list     = zones     |> Enum.map(fn x -> x.text end)
      addresses_list = addresses |> Enum.map(fn x -> x.text end)
      status_list    = status    |> Enum.map(fn x -> x.text end)
      storage_list   = storage   |> Enum.map(fn x -> x.text end)        

      List.zip(
        [ids_list]       
        ++ [zones_list]     
        ++ [addresses_list] 
        ++ [status_list]    
        ++ [storage_list]
      )
    end

    def get_instance(instance, fun \\ &ExAws.RDS.Impl.describe_db_instances/2) do 
      result = 
        for region <- Helper.get_regions do
          case fun.(ExAws.RDS.new(region: region), %{"DBInstanceIdentifier" => instance}) do 
            {:ok, res} ->
              case res.status_code do 
                200 ->
                  name    = res.body
                  |> Friendly.find("dbinstanceidentifier")
                  |> List.first
                  |> Map.get(:text)
                  region  = res.body
                  |> Friendly.find("availabilityzone")
                  |> List.first
                  |> Map.get(:text)            
                  address = res.body
                  |> Friendly.find("address")
                  |> List.first
                  |> Map.get(:text)
                  status  = res.body
                  |> Friendly.find("dbinstancestatus")
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
              parse_http_error reason
          end
        end
        |> List.flatten

      case val = Enum.find(result, fn x -> is_tuple(x) end) do
        nil -> Enum.find(result, fn x -> is_binary(x) end)
        _   -> val
      end
    end

    def get_instance!(instance, fun \\ &describe_db_instances/1), do: fun.(%{"DBInstanceIdentifier" => instance})

    def insert_instance(instance, settings, {region, tier}, _credentials = {username, password}, addresses, fun \\ &create_db_instance/7) do 
      storage  = settings.storage
      engine   = settings.engine
      settings = Map.put(settings, "VpcSecurityGroups.member.1", "secgroup-#{instance}")

      if Mix.env() != :test do
        if addresses == [] do 
          Helper.create_sg_with_local_public_ip_allowed(instance, engine)
        else
          Helper.create_sg_for_many_ips(instance, engine, addresses)
        end
      end

      case fun.(instance, username, password, storage, tier, engine, settings) do 
        {:ok, res} ->
          case res.status_code do 
            200 -> :ok
            _   -> get_error_message res
          end
        {:error, reason} ->
          parse_http_error reason
      end
    end

    def insert_instance!(instance, settings, {region, tier}, {username, password}, addresses, fun \\ &create_db_instance/7) do 
      storage  = settings.storage
      engine   = settings.engine
      settings = Map.put(settings, "VpcSecurityGroups.member.1", "secgroup-#{instance}")

      if Mix.env() != :test do
        if addresses == [] do
          Helper.create_sg_with_local_public_ip_allowed(instance, engine)
        else
          Helper.create_sg_for_many_ips(instance, engine, addresses)
        end
      end

      fun.(instance, username, password, storage, tier, engine, settings)
    end

    def delete_instance(instance, fun \\ &delete_db_instance/1) do 
      case fun.(instance) do 
        {:ok, res} ->
          case res.status_code do 
            200 -> :ok
            _   -> get_error_message res
          end
        {:error, reason} ->
          parse_http_error reason
      end
    end

    def delete_instance!(instance, fun \\ &delete_db_instance/1), do: fun.(instance)

    def restart_instance(instance, fun \\ &reboot_db_instance/1) do
      case fun.(instance) do 
        {:ok, res} ->
          case res.status_code do 
            200 -> :ok
            _   -> get_error_message res
          end
        {:error, reason} ->
          parse_http_error reason
      end
    end

    def restart_instance!(instance, fun \\ &reboot_db_instance/1), do: fun.(instance)

    def list_databases(instance, fun \\ &describe_db_instances/1) do 
      case fun.(%{"DBInstanceIdentifier" => instance}) do 
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
          parse_http_error reason
      end
    end

    def list_databases!(instance, fun \\ &describe_db_instances/1), do: fun.(%{"DBInstanceIdentifier" => instance})

    def list_classes do
      ["db.t1.micro",    "db.m1.small",   "db.m1.medium",  "db.m1.large", 
        "db.m1.xlarge",   "db.m2.xlarge",  "db.m2.2xlarge", "db.m2.4xlarge", 
        "db.m3.medium",   "db.m3.large",   "db.m3.xlarge",  "db.m3.2xlarge",
        "db.m4.large",    "db.m4.xlarge",  "db.m4.2xlarge", "db.m4.4xlarge",
        "db.m4.10xlarge", "db.r3.large",   "db.r3.xlarge",  "db.r3.2xlarge", 
        "db.r3.4xlarge",  "db.r3.8xlarge", "db.t2.micro",   "db.t2.small",
        "db.t2.medium",   "db.t2.large"]
    end

    def get_instance_address(instance, fun \\ &get_instance/1) do 
      case fun.(instance) do 
        {_, _, address, _, _} -> address
        msg -> msg
      end
    end
  end

  defmodule Nomad.AWS.SQL.Helper do
    use ExAws.EC2.Client
    import Nomad.Utils

    @mdoc false
    
    def config_root do 
      Application.get_all_env(:my_aws_config_root)
    end      

    @doc """
    Create a new Security Group that enables inbound traffic from the 
    current local machine's public IP address. The Security Group will have
    the name 'secgroup-<instance>' and the port used will be determined by
    the provided SQL 'engine'.
    """
    @spec create_sg_with_local_public_ip_allowed(instance :: binary, engine :: binary) :: :ok | :error
    def create_sg_with_local_public_ip_allowed(instance, engine) do 
      group = "secgroup-#{instance}"
      ip    = find_public_ip_address
      port  = determine_port engine

      create_security_group(group, "Security Group for the instance #{instance}.")

      res = authorize_security_group_ingress(
        [
          group_name:                          group, 
          "IpPermissions.1.IpProtocol":        "tcp",
          "IpPermissions.1.FromPort":          port,
          "IpPermissions.1.ToPort":            port,
          "IpPermissions.1.IpRanges.1.CidrIp": ip <> "/32"
        ])
      
      case res do
        {:ok, _} -> :ok
        _        -> :error
      end
    end

    @doc"""
    Create a new Security Group that enables inbound traffic from the
    current local machine's public IP address as well as the addresses 
    provided. The Security Group will have the name 'secgroup-<instance>' 
    and the port used will be determined by the provided SQL 'engine'.
    """
    @spec create_sg_for_many_ips(instance :: binary, engine :: binary, ips :: [binary]) :: :ok | :error
    def create_sg_for_many_ips(instance, engine, ips) do
      group     = "secgroup-#{instance}"
      public_ip = find_public_ip_address
      port      = determine_port engine
      count     = 1
      opts_list = ip_list_builder(ips ++ [public_ip], port, count, []) |> List.flatten

      create_security_group(group, "Security Group for the instance #{instance}.")

      case authorize_security_group_ingress([group] ++ opts_list) do
        {:ok, _} -> :ok
        _        -> :error
      end
    end

    defp ip_list_builder([h | []], port, count, state) do
      elem = 
        [
          "IpPermissions.#{count}.IpProtocol":               "tcp",
          "IpPermissions.#{count}.FromPort":                 port,
          "IpPermissions.#{count}.ToPort":                   port,
          "IpPermissions.#{count}.IpRanges.#{count}.CidrIp": h <> "/32" 
        ]

      state ++ elem
    end

    defp ip_list_builder([h | t], port, count, state) do
      elem = 
        [
          "IpPermissions.#{count}.IpProtocol":               "tcp",
          "IpPermissions.#{count}.FromPort":                 port,
          "IpPermissions.#{count}.ToPort":                   port,
          "IpPermissions.#{count}.IpRanges.#{count}.CidrIp": h <> "/32" 
        ]

      ip_list_builder(t, port, count + 1, state ++ elem)
    end

    defp determine_port(engine) do 
      case String.upcase(engine) do
        "MYSQL"         -> 3306
        "MARIADB"       -> 3306
        "POSTGRES"      -> 5432
        "ORACLE-SE1"    -> 1521
        "ORACLE-SE"     -> 1521
        "ORACLE-EE"     -> 1521
        "SQLSERVER-EE"  -> 1433
        "SQLSERVER-SE"  -> 1433
        "SQLSERVER-EX"  -> 1433
        "SQLSERVER-WEB" -> 1433
        "AURORA"        -> 3306 
      end
    end

    def get_regions, do: Nomad.AWS.VirtualMachines.list_regions
  end
end

