defmodule NomadSQL do

  @doc """
  Lists all database instances for the given cloud credentials. The function
  returns a list of tuples with the following format:
    {instance_name, region, address, status, allocated_storage}
  """  
  @callback list_instances() :: list(tuple) | [] | binary

  @doc """
  Returns a tuple with info about the given 'instance' with the format:
    {instance_name, region, address, status, allocated_storage}
  """  
  @callback get_instance(instance :: binary) :: map | binary

  @doc """
  Creates a new database instance with name 'instance', the provided 
  'settings' and in the desired pricing/performance 'tier'.

  The 'settings' must be passed as a Map in the format: %{key: value}
  """  
  @callback insert_instance(instance :: binary, settings :: map | list, {region :: binary, tier :: binary}, {user :: binary, password :: binary}, addresses :: list) :: :ok | binary

  @doc """
  Deletes the given 'instance'.
  """  
  @callback delete_instance(instance :: binary) :: :ok | binary

  @doc """
  Restarts the given 'instance'.
  """  
  @callback restart_instance(instance :: binary) :: :ok | binary

  @doc """
  Lists all the available databases in the given 'instance'.
  """
  @callback list_databases(instance :: binary) :: [binary] | binary

  @doc """
  Lists all instance classes/tiers for the given cloud provier's SQL service.
  """
  @callback list_classes() :: [binary]

  @doc """
  Returns the address for the given 'instance'.
  """
  @callback get_instance_address(instance :: binary) :: binary
  
end