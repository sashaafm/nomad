defmodule Mix.Tasks.Nomad.Storage.Create do
  use Mix.Task

  @moduledoc"""
  Task for automatically creating a remote storage on a pre-determined cloud
  provider. The storage creation is done through the cloud provider's API.

  Usage:

    mix nomad.storage.create
    # Will be prompted for data

    mix nomad.storage.create <name> <region> <class>
    # Will create the storage automatically
  """

  @shortdoc"Create a storage on the chosen cloud provider's storage service."

  def run(args) do
    case Application.get_env(:nomad, :cloud_provider) do
      :aws ->
        Application.ensure_all_started(:ex_aws)
        Application.ensure_all_started(:httpoison)
      :gcl ->
        Application.ensure_all_started(:httpoison)
        Application.ensure_all_started(:goth)
        Application.ensure_all_started(:gcloudex)
    end

    create_storage args
  end

  defp create_storage([]) do
    region = Mix.Shell.IO.prompt("Insert the region for the storage: ") |> String.rstrip
    class  = Mix.Shell.IO.prompt("Insert the storage class (#{get_classes}): ") |> String.rstrip
    name   = Mix.Shell.IO.prompt("Insert the name for the storage: ") |> String.rstrip

    Mix.Shell.IO.info("\n")
    Mix.Shell.IO.info("########################### SUMMARY #########################\n")

    summary = "The storage will be created with the following settings:\n"
    <> "Region: #{region}\n"
    <> "Class:  #{class}\n"
    <> "Name:   #{name}\n"
    <> "Do you confirm?\n"

    if Mix.Shell.IO.yes?(summary) do
      create region, class, name
    else
      create_storage []
    end
  end

  defp create([name, region, class]) do
    create region, class, name
  end

  defp create(region, class, name) do
    case Nomad.Storage.create_storage name, region, class do
      :ok -> Mix.Shell.IO.info("The storage has been created successfully.")
      msg -> Mix.Shell.IO.info("A problem has occurred: \n#{msg}")
    end
  end

  defp get_classes do
    Enum.join(Nomad.Storage.list_classes, ", ")
  end
end
