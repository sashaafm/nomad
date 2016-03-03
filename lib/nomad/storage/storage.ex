defmodule Nomad.Storage do
  alias Cloud.Storage, as: CS

  def list_storages do 
    CS.list_storages
  end

  def create_storage(name, region) do 
    CS.create_bucket name, region
  end

  def put_item(storage, name, content) do 
    CS.put_item storage, name, content
  end

  def list_items(storage) do 
    CS.list_items storage
  end
  
end