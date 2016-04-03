defmodule Nomad.SQL do
  alias Cloud.SQL, as: CS

  @moduledoc """
  Interface for the Nomad SQL API. All the functions here will call their
  respective callbacks to the desired cloud's client adapter.  
  """

  @behaviour NomadSQL

  def list_instances do
    CS.list_instances
  end
  
  def get_instance(instance) do 
    CS.get_instance instance
  end

  def insert_instance(instance, settings, tier) do 
    CS.insert_instance instance, settings, tier
  end

  def delete_instance(instance) do 
    CS.delete_instance instance
  end

  def restart_instance(instance) do 
    CS.restart_instance instance
  end

  def list_databases(instance) do 
    CS.list_databases instance
  end
end