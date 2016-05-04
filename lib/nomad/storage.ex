defmodule Nomad.Storage do
  
  @moduledoc """
  Interface for the Nomad Storage API. All the functions here will call their
  respective callbacks to the desired cloud's client adapter.
  """

  case Application.get_env(:nomad, :cloud_provider) do 
    :aws -> use Nomad.AWS.Storage, :aws
    :gcl -> use Nomad.GCL.Storage, :gcl
  end
end
