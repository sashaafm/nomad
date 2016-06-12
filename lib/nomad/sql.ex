defmodule Nomad.SQL do

  @moduledoc """
  Interface for the Nomad SQL API. All the functions here will call their
  respective callbacks to the desired cloud's client adapter.

  To use the SQL API - at least - the following system variables must be 
  passed on startup:

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

  case Application.get_env(:nomad, :cloud_provider) do 
    :aws -> use Nomad.AWS.SQL, :aws
    :gcl -> use Nomad.GCL.SQL, :gcl
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
