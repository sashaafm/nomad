defmodule Script do

  @moduledoc """
  
  """

  @callback build_script() :: :ok
  @callback bs :: String.t
  @callback delete_script :: :ok

  
end