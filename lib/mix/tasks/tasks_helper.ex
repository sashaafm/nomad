defmodule Nomad.TasksHelper do

  @moduledoc"""
  Offers useful helper functions for the Nomad Mix Tasks.
  """

  @doc"""
  Starts all the dependency apps for the given adapter.
  """
  @spec start_apps_for_adapter(adapter :: atom) :: :ok
  def start_apps_for_adapter(adapter) do
    for app <- apps_for_adapter(adapter) do
      Application.ensure_all_started(app)
    end

    :ok
  end

  @doc"""
  Returns a list of all the needed depedency apps for the given adapter.
  """
  @spec apps_for_adapter(adapter :: atom) :: list(atom)
  def apps_for_adapter(adapter), do: afa adapter

  defp afa(:aws) do
    [:ex_aws, :httpoison]
  end

  defp afa(:gcl) do
    [:httpoison, :goth, :gcloudex]
  end

  @doc"""
  Returns the chosen cloud provider.
  """
  @spec get_provider() :: atom
  def get_provider, do: Application.get_env(:nomad, :cloud_provider)
end
