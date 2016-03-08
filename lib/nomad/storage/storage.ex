defmodule Nomad.Storage do
  alias Cloud.Storage, as: CS

  @moduledoc """
  
  """

  def list_storages do 
    CS.list_storages
  end

  def create_storage(name) do 
    CS.create_storage name
  end

  def create_storage(name, region) do 
    CS.create_storage name, region
  end

  def create_storage(name, region, class) do 
    CS.create_storage name, region, class
  end

  def put_item(storage, filepath) do 
    CS.put_item storage, filepath
  end

  def list_items(storage) do 
    CS.list_items storage
  end

  def delete_item(storage, item) do 
    CS.delete_item storage, item
  end

  def get_item(storage, item) do
    CS.get_item storage, item
  end

  def get_item_acl(storage, item) do 
    CS.get_item_acl storage, item
  end

  def delete_storage(storage) do
    CS.delete_storage storage
  end

  def get_storage_region(storage) do
    CS.get_storage_region storage
  end

  def get_storage_class(storage) do 
    CS.get_storage_class storage
  end

  def get_storage_acl(storage) do 
    CS.get_storage_acl storage
  end
  
end
