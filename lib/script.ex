defmodule Script do

  @moduledoc """
  Defines the behaviour of Script.
  """

  @callback build_script() :: :ok
  @callback delete_script :: :ok  
end
