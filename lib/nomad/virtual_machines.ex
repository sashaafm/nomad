defmodule Nomad.VirtualMachines do

  @moduledoc """
  
  """

  case Application.get_env(:nomad, :cloud_provider) do 
    :aws -> use Nomad.AWS.VirtualMachines, :aws
    :gcl -> use Nomad.GCL.VirtualMachines, :gcl
  end
end
