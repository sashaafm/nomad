defmodule Mix.Tasks.Nomad.DatabaseInstance.List do
  use Mix.Task

  @moduledoc """
  
  """

  @shortdoc"""
  """

  @doc """
  
  """
  def run(args) do 
    case System.get_env("PROVIDER") do 
      "AWS" -> list_instances_aws args

      "GCL" -> list_instances_gcl args
    end
  end

  defp list_instances_aws(_args) do
    Application.ensure_all_started :nomad_aws

    list_instances_api_call
  end

  defp list_instances_gcl(_args) do 
    Application.ensure_all_started :nomad_gcl

    list_instances_api_call
  end

  defp list_instances_api_call do
    res = Nomad.SQL.list_instances

    if is_list(res) do 
      Mix.Shell.IO.info("Name | Region | Address | Status | Storage")

      res
      |> Enum.map(fn {a, b, c, d, e} -> 
                    Mix.Shell.IO.info("#{a} | #{b} | #{c} | #{d} | #{e}")
                  end)
    else
      Mix.Shell.IO.info("There was a problem listing the instances:\n#{res}")
    end
  end
  
end