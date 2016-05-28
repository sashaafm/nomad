defmodule Nomad.VirtualMachines do

  @moduledoc """
  Interface for the Nomad Virtual Machines API. All the functions here will call
  their respective callbacks generated from the desired cloud's client adapter.
  """

  case Application.get_env(:nomad, :cloud_provider) do 
    :aws -> use Nomad.AWS.VirtualMachines, :aws
    :gcl -> use Nomad.GCL.VirtualMachines, :gcl
  end
end
