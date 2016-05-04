defmodule NomadStorage do 
  
  @doc """
  Lists all the available storages for the chosen cloud 
  provider's storage service.
  """  
  @callback list_storages() :: [binary] | binary

  @doc """
  Creates a storage (a bucket) for the chosen cloud provider's
  storage service.
  """
  @callback create_storage(binary) :: :ok | binary

  @doc """
  Creates a storage (a bucket) for the chosen cloud provider's
  storage service in the desired 'region'.
  """
  @callback create_storage(binary, binary) :: :ok | binary

  @doc """
  Creates a storage (a bucket) for the chosen cloud provider's
  storage service in the desired 'region'.
  """  
  @callback create_storage(binary, binary, binary) :: :ok | binary

  @doc """
  Uploads the file in 'filepath' to the given 'storage'.
  """
  @callback put_item(binary, binary) :: :ok | binary

  @doc"""
  Uploads the file in 'filepath' to the given 'storage' and stores it
  in the specified 'storage_path'. The necessaries directories in 
  'storage_path' will be created if they do not exist.
  """  
  @callback put_item(binary, binary, binary) :: :ok | binary

  @doc """
  Deletes the file in 'item' in the given 'storage'.
  """
  @callback delete_item(binary, binary) :: :ok | binary

  @doc """
  Downloads the given 'item' in the given 'storage'.
  """
  @callback get_item(binary, binary) :: :ok | binary

  @doc """
  Retrieves the given 'item's ACL  in the given 'storage'.
  """
  @callback get_item_acl(binary, binary) :: [{binary, binary}] | binary 

  @doc """
  Lists all the available files in the given 'storage'.
  """
  @callback list_items(binary) :: [binary] | binary

  @doc """
  Deletes the given 'storage'. Usually the storage must be empty before
  deletion.
  """
  @callback delete_storage(binary) :: :ok | binary

  @doc """
  Returns the given 'storage' region.
  """
  @callback get_storage_region(binary) :: binary

  @doc """
  Returns the given 'storage' class.
  """
  @callback get_storage_class(binary) :: binary

  @doc """
  Returns the given 'storage' ACL.
  """
  @callback get_storage_acl(binary) :: [{binary, binary}] | binary 

  @doc """
  Lists the available classes for the storages.
  """
  @callback list_classes() :: [binary]
end
