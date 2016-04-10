defmodule Nomad.SQL do
  alias Cloud.SQL, as: CS

  @moduledoc """
  Interface for the Nomad SQL API. All the functions here will call their
  respective callbacks to the desired cloud's client adapter.

  To use the SQL API the following system variables must be passed on startup:
    DB_NAME:     The name of the database
    DB_INSTANCE: The instance to which the database belongs
    DB_USERNAME: The username for the given database
    DB_PASSWORD: The password for the given database

    The hostname will be retrieved through the API.

  To use the SQL API and the regular Ecto Mix tasks:
    DB_NAME:     The name of the database
    DB_INSTANCE: The instance to which the database belongs
    DB_USERNAME: The username for the given database
    DB_PASSWORD: The password for the given database
    DB_HOSTNAME: The host for the given database instance
  """

  @behaviour NomadSQL

  @doc """
  Lists all database instances for the given cloud credentials. The function
  returns a list of tuples with the following format:
    {instance_name, region, address, status, allocated_storage}
  """
  @spec list_instances() :: [tuple]
  def list_instances do
    CS.list_instances
  end
  
  @doc """
  Returns a tuple with info about the given 'instance' with the format:
    {instance_name, region, address, status, allocated_storage}
  """
  @spec get_instance(binary) :: tuple
  def get_instance(instance) do 
    CS.get_instance instance
  end

  @doc """
  Creates a new database instance with name 'instance', the provided 
  'settings' and in the desired pricing/performance 'tier'.

  The 'settings' must be passed as a Map in the format: %{key: value}
  """
  @spec insert_instance(binary, map, binary) :: :ok | binary
  def insert_instance(instance, settings, tier) do 
    CS.insert_instance instance, settings, tier
  end

  @doc """
  Deletes the given 'instance'.
  """
  @spec delete_instance(binary) :: :ok | binary
  def delete_instance(instance) do 
    CS.delete_instance instance
  end

  @doc """
  Restarts the given 'instance'.
  """
  @spec restart_instance(binary) :: :ok | binary
  def restart_instance(instance) do 
    CS.restart_instance instance
  end

  @doc """
  Lists all the available databases in the given 'instance'.
  """
  @spec list_databases(binary) :: [binary]
  def list_databases(instance) do 
    CS.list_databases instance
  end

  @doc """
  Lists all instance classes/tiers for the given cloud provier's SQL service.
  """
  @spec list_classes() :: [binary]
  def list_classes do 
    CS.list_classes
  end

  @doc """
  Returns the address for the given 'instance'.
  """
  @spec get_instance_address(binary) :: binary
  def get_instance_address(instance) do 
    CS.get_instance_address instance
  end

  @doc """
  Sets the database host (for Ecto).
  """
  @spec set_database_host(atom, atom) :: :ok
  def set_database_host(app_name, module) do 
    hostname = Nomad.SQL.get_instance_address(System.get_env("DB_INSTANCE"))

    new_env  = Application.get_env(app_name, module)
               |> Keyword.put(:hostname, hostname)

    Application.put_env(app_name, module, new_env, persistent: true)    
  end
end