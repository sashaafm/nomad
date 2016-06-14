defmodule NomadStorage do 

  @doc """
  Lists all the available storages for the chosen cloud 
  provider's storage service.
  """  
  @callback list_storages() :: [binary] | binary

  @doc"""
  Same as list_storages/0 but returns the complete HTTP reply.
  """
  @callback list_storages!() :: HTTPoison.Response.t

  @doc """
  Creates a storage (a bucket) for the chosen cloud provider's
  storage service in the desired 'region'.
  """  
  @callback create_storage(storage :: binary, region :: binary, class :: binary) :: :ok | binary

  @doc"""
  Same as create_storage/3 but returns the complete HTTP reply.
  """
  @callback create_storage!(storage :: binary, region :: binary, class :: binary) :: HTTPoison.Response.t

  @doc"""
  Uploads the file in 'filepath' to the given 'storage' and stores it
  in the specified 'storage_path'. The necessaries directories in 
  'storage_path' will be created if they do not exist.
  """  
  @callback put_item(storage :: binary, filepath :: binary, storage_path :: binary) :: :ok | binary

  @doc"""
  Same as put_item/3 but returns the complete HTTP reply.
  """
  @callback put_item!(storage :: binary, filepath :: binary, storage_path :: binary) :: HTTPoison.Response.t

  @doc"""
  Deletes the file in 'item' in the given 'storage'.
  """
  @callback delete_item(storage :: binary, item :: binary) :: :ok | binary

  @doc"""
  Same as delete_item/2 but returns the complete HTTP reply.
  """
  @callback delete_item!(storage :: binary, item :: binary) :: HTTPoison.Response.t

  @doc"""
  Downloads the given 'item' in the given 'storage'.
  """
  @callback get_item(storage :: binary, item :: binary) :: :ok | binary

  @doc"""
  Same as get_item/2 but returns the complete HTTP reply.
  """
  @callback get_item!(storage :: binary, item :: binary) :: HTTPoison.Response.t

  @doc"""
  Retrieves the given 'item's ACL  in the given 'storage'.
  """
  @callback get_item_acl(binary, binary) :: [{binary, binary}] | binary 

  @doc"""
  Same as get_item_acl/2 but returns the complete HTTP reply.
  """
  @callback get_item_acl!(storage :: binary, item :: binary) :: HTTPoison.Response.t

  @doc"""
  Lists all the available files in the given 'storage'.
  """
  @callback list_items(storage :: binary) :: [binary] | binary

  @doc"""
  Same as list_items/1 but returns the complete HTTP reply.
  """
  @callback list_items!(storage :: binary) :: HTTPoison.Response.t

  @doc"""
  Deletes the given 'storage'. Usually the storage must be empty before
  deletion.
  """
  @callback delete_storage(storage :: binary) :: :ok | binary

  @doc"""
  Same as delete_storage/1 but returns the complete HTTP reply.
  """
  @callback delete_storage!(storage :: binary) :: HTTPoison.Response.t

  @doc"""
  Returns the given 'storage' region.
  """
  @callback get_storage_region(storage :: binary) :: binary

  @doc"""
  Same as get_storage_region/1 but returns the complete HTTP reply.
  """
  @callback get_storage_region!(storage :: binary) :: HTTPoison.Response.t

  @doc"""
  Returns the given 'storage' class.
  """
  @callback get_storage_class(storage :: binary) :: binary

  @doc """
  Returns the given 'storage' ACL.
  """
  @callback get_storage_acl(binary) :: [{binary, binary}] | binary 

  @doc"""
  Same as get_storage_acl/1 but returns the complete HTTP reply.
  """
  @callback get_storage_acl!(storage :: binary) :: HTTPoison.Response.t

  @doc """
  Lists the available classes for the storages.
  """
  @callback list_classes() :: [binary]
end
