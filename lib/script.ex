defmodule Script do

  @moduledoc """
  Defines the behaviour of Script.
  """
  
  @doc """
  Builds and writes the bash script to the respective .sh file.
  """
  @callback build_script() :: :ok

  @doc """
  Deletes the script .sh file from the local machine.
  """
  @callback delete_script :: :ok  
end
