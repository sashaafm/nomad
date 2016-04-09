defmodule Nomad.Storage do
  alias Cloud.Storage, as: CS

  @moduledoc """
  Interface for the Nomad Storage API. All the functions here will call their
  respective callbacks to the desired cloud's client adapter.
  """

  @behaviour NomadStorage

  @doc """
  Lists all the available storages for the chosen cloud 
  provider's storage service.
  """
  @spec list_storages() :: [binary]
  def list_storages do 
    CS.list_storages
  end

  @doc """
  Creates a storage (a bucket) for the chosen cloud provider's
  storage service.
  """
  @spec create_storage(binary) :: :ok | :error

  def create_storage(name) do 
    CS.create_storage name
  end

  @doc """
  Creates a storage (a bucket) for the chosen cloud provider's
  storage service in the desired 'region'.
  """
  @spec create_storage(binary, binary) :: :ok | :error

  def create_storage(name, region) do 
    CS.create_storage name, region
  end
  
  @doc """
  Creates a storage (a bucket) belonging to the given 'class' for the chosen 
  cloud provider's storage service in the desired 'region'.
  """
  @spec create_storage(binary, binary, binary) :: :ok | :error
  
  def create_storage(name, region, class) do 
    CS.create_storage name, region, class
  end

  @doc """
  Uploads the file in 'filepath' to the given 'storage'.
  """
  @spec put_item(binary, binary) :: :ok | :error

  def put_item(storage, filepath) do 
    CS.put_item storage, filepath
  end

  @doc"""
  Uploads the file in 'filepath' to the given 'storage' and stores it
  in the specified 'storage_path'. The necessaries directories in 
  'storage_path' will be created if they do not exist.
  """
  
  def put_item(storage, filepath, storage_path) do 
    CS.put_item storage, filepath, storage_path
  end


  @doc """
  Lists all the available files in the given 'storage'.
  """
  @spec list_items(binary) :: [binary] | :error

  def list_items(storage) do 
    CS.list_items storage
  end

  @doc """
  Deletes the file in 'item' in the given 'storage'.
  """
  @spec delete_item(binary, binary) :: :ok | :error

  def delete_item(storage, item) do 
    CS.delete_item storage, item
  end

  @doc """
  Downloads the given 'item' in the given 'storage'.
  """
  @spec get_item(binary, binary) :: :ok | :error

  def get_item(storage, item) do
    CS.get_item storage, item
  end

  @doc """
  Retrieves the given 'item's ACL  in the given 'storage'.
  """
  @spec get_item_acl(binary, binary) :: [{binary, binary}]

  def get_item_acl(storage, item) do 
    CS.get_item_acl storage, item
  end

  @doc """
  Deletes the given 'storage'. Usually the storage must be empty before
  deletion.
  """
  @spec delete_storage(binary) :: :ok | :error

  def delete_storage(storage) do
    CS.delete_storage storage
  end

  @doc """
  Returns the given 'storage' region.
  """
  @spec get_storage_region(binary) :: binary | :error

  def get_storage_region(storage) do
    CS.get_storage_region storage
  end

  @doc """
  Returns the given 'storage' class.
  """
  @spec get_storage_class(binary) :: binary | :error

  def get_storage_class(storage) do 
    CS.get_storage_class storage
  end

  @doc """
  Returns the given 'storage' ACL.
  """
  @spec get_storage_acl(binary) :: binary | :error

  def get_storage_acl(storage) do 
    CS.get_storage_acl storage
  end
 
  def list_classes do
    CS.list_classes
  end
end
