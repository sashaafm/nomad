defmodule NomadVirtualMachines do

  @doc"""
  Lists all Virtual Machines in the given 'region' with their names, status, class and public IP.
  """
  @callback list_virtual_machines(region :: binary) :: [{binary, binary, binary, binary}] | binary

  @doc"""
  Same as list_virtual_machines/1 but returns the complete HTTP reply.
  """
  @callback list_virtual_machines!(region :: binary) :: HTTPoison.Response.t

  @doc"""
  Returns the Virtal Machine 'instance' name, status, public IP and class.
  """
  @callback get_virtual_machine(region :: binary, instance :: binary) :: {binary, binary, binary, binary} 

  @doc"""
  Same as get_virtual_machine/2 but returns the complete HTTP reply.
  """
  @callback get_virtual_machine!(region :: binary, instance :: binary) :: HTTPoison.Response.t

  @doc"""
  Creates a new Virtual Machine in the given 'region' using the provided 'class', 'image' and 'auto_delete' behaviour.
  """
  @callback create_virtual_machine(region :: binary, class :: binary, image :: binary, auto_delete :: boolean) :: :ok | binary

  @doc"""
  Same as create_virtual_machine/4 but returns the complete HTTP reply.
  """
  @callback create_virtual_machine!(region :: binary, class :: binary, image :: binary, auto_delete :: boolean) :: HTTPoison.Response.t

  @doc"""
  Deletes the Virtual Machine 'instance' in the given 'region'.
  """
  @callback delete_virtual_machine(region :: binary, instance :: binary) :: :ok | binary

  @doc"""
  Same as delete_virtual_machine/2 but returns the complete HTTP reply.
  """
  @callback delete_virtual_machine!(region :: binary, instance :: binary) :: HTTPoison.Response.t

  @doc"""
  Starts the Virtual Machine 'instance' in the given 'region'.
  """
  @callback start_virtual_machine(region :: binary, instance :: binary) :: :ok | binary

  @doc"""
  Same as start_virtual_machine/2 but returns the complete HTTP reply.
  """
  @callback start_virtual_machine!(region :: binary, instance :: binary) :: HTTPoison.Response.t

  @doc"""
  Stops the Virtual Machine 'instance' in the given 'region'.
  """
  @callback stop_virtual_machine(region :: binary, instance :: binary) :: :ok | binary

  @doc"""
  Same as stop_virtual_machine/2 but returns the complete HTTP reply.
  """
  @callback stop_virtual_machine!(region :: binary, instance :: binary) :: HTTPoison.Response.t

  @doc"""
  Reboots the Virtual Machine 'instance' in the given 'region'.
  """
  @callback reboot_virtual_machine(region :: binary, instance :: binary) :: :ok | binary

  @doc"""
  Same as reboot_virtual_machine/2 but returns the complete HTTP reply.
  """
  @callback reboot_virtual_machine!(region :: binary, instance :: binary) :: HTTPoison.Response.t

  @doc"""
  Sets the Virtual Machine 'instance' in the given 'region' to the specified 'class' if possible.
  """
  @callback set_virtual_machine_class(region :: binary, instance :: binary, class :: binary) :: :ok | binary

  @doc"""
  Same as set_virtual_machine_class/3 but returns the complete HTTP reply.
  """
  @callback set_virtual_machine_class!(region :: binary, instance :: binary, class :: binary) :: HTTPoison.Response.t

  @doc"""
  Lists all disks in the given 'region' indicating their names, sizes, images, statuses and types.
  """
  @callback list_disks(region :: binary) :: [{binary, binary, binary, binary, binary}] | binary

  @doc"""
  Same as list_disks/1 but returns the complete HTTP reply.
  """
  @callback list_disks!(region :: binary) :: HTTPoison.Response.t

  @doc"""
  Returns the specified 'disk' name, size, image, status and type.
  """
  @callback get_disk(region :: binary, disk :: binary) :: {binary, binary, binary, binary, binary} | binary

  @doc"""
  Same as get_disk/2 but returns the complete HTTP reply.
  """
  @callback get_disk!(region :: binary, disk :: binary) :: HTTPoison.Response.t

  @doc"""
  Creates an empty persistent disk in the given 'region' with the specified 'size'. 
  """
  @callback create_disk(region :: binary, size :: integer) :: :ok | binary

  @doc"""
  Same as create_disk/2 but returns the complete HTTP reply.
  """
  @callback create_disk!(region :: binary, size :: integer) :: HTTPoison.Response.t

  @doc"""
  Creates a bootable disk in the given 'region' with the specified 'size' and 'image'.
  """
  @callback create_disk(region :: binary, size :: integer, image :: binary) :: :ok | binary

  @doc"""
  Same as create_disk/3 but returns the complete HTTP reply.
  """
  @callback create_disk!(region :: binary, size :: integer, image :: binary) :: HTTPoison.Response.t

  @doc"""
  Deletes the given 'disk' in the specified 'region'.
  """
  @callback delete_disk(region :: binary, disk :: binary) :: :ok | binary

  @doc"""
  Same as delete_disk/2 but returns the complete HTTP reply.
  """
  @callback delete_disk!(region :: binary, disk :: binary) :: HTTPoison.Response.t

  @doc"""
  Attaches the given 'disk' to the specified 'instance' and with the provided 'device_name'.
  """
  @callback attach_disk(region :: binary, instance :: binary, disk :: binary, device_name :: binary) :: :ok | binary

  @doc"""
  Same as attach_disk/4 but returns the complete HTTP reply.
  """
  @callback attach_disk!(region :: binary, instance :: binary, disk :: binary, device_name :: binary) :: HTTPoison.Response.t

  @doc"""
  Detaches the given 'disk' from the 'instance'.
  """
  @callback detach_disk(region :: binary, instance :: binary, disk :: binary) :: :ok | binary

  @doc"""
  Same as detach_disk/3 but returns the complete HTTP reply.
  """
  @callback detach_disk!(region :: binary, instance :: binary, disk :: binary) :: HTTPoison.Response.t

  @doc"""
  Lists all available regions (and their zones if possible).
  """
  @callback list_regions() :: [binary] | [{binary, [binary]}]

  @doc"""
  Same as list_regions/0 but returns the complete HTTP reply.
  """
  @callback list_regions!() :: HTTPoison.Response.t

  @doc"""
  Lists all available Virtual Machine classes.
  """
  @callback list_classes() :: [binary]
end
