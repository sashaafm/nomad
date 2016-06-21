defmodule NomadSQL do

  @doc """
  Lists all database instances for the given cloud credentials. The function
  returns a list of tuples with the following format:
    {instance_name, region, address, status, allocated_storage}
  """  
  @callback list_instances() :: list(tuple) | [] | binary

  @doc"""
  Same as list_instances/0 but returns the complete HTTP reply.
  """
  @callback list_instances!() :: HTTPoison.Response.t

  @doc"""
  Returns a tuple with info about the given 'instance' with the format:
    {instance_name, region, address, status, allocated_storage}
  """  
  @callback get_instance(instance :: binary) :: map | binary

  @doc"""
  Same as get_instance/1 but returns the complete HTTP reply.
  """
  @callback get_instance!(instance :: binary) :: HTTPoison.Response.t

  @doc"""
  Creates a new database instance with name 'instance', the provided 
  'settings' and in the desired pricing/performance 'tier'.

  The 'settings' must be passed as a Map in the format: %{key: value}
  """  
  @callback insert_instance(instance :: binary, settings :: map | list, {region :: binary, tier :: binary}, {username :: binary, password :: binary}, addresses :: list) :: :ok | binary

  @doc"""
  Same as insert_instance/5 but returns the complete HTTP reply.
  """
  @callback insert_instance!(instance :: binary, settings :: map | list, {region :: binary, tier :: binary}, {username :: binary, password :: binary}, addresses :: list) :: HTTPoison.Response.t

  @doc"""
  Deletes the given 'instance'.
  """  
  @callback delete_instance(instance :: binary) :: :ok | binary

  @doc"""
  Same as delete_instance/1 but returns the complete HTTP reply.
  """
  @callback delete_instance!(instance :: binary) :: HTTPoison.Response.t

  @doc"""
  Restarts the given 'instance'.
  """  
  @callback restart_instance(instance :: binary) :: :ok | binary

  @doc"""
  Same as restart_instance/1 but returns the complete HTTP reply.
  """
  @callback restart_instance!(instance :: binary) :: HTTPoison.Response.t

  @doc"""
  Lists all the available databases in the given 'instance'.
  """
  @callback list_databases(instance :: binary) :: [binary] | binary

  @doc"""
  Same as list_databases/1 but returns the complete HTTP reply.
  """
  @callback list_databases!(instance :: binary) :: HTTPoison.Response.t

  @doc"""
  Lists all instance classes/tiers for the given cloud provier's SQL service.
  """
  @callback list_classes() :: [binary]

  @doc"""
  Returns the address for the given 'instance'.
  """
  @callback get_instance_address(instance :: binary) :: binary
end

