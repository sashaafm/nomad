defmodule Nomad do
  use Application
  
  @moduledoc """
  
  """

  def start(:nomad, :temporary) do
    clean_deps
  end

  defp clean_deps do 
    Mix.Task.run "deps.clean", ["--unused"]
  end
end
