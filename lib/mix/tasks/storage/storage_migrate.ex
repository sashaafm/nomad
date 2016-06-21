defmodule Mix.Tasks.Nomad.Storage.Migrate do
  use Mix.Task
  #case Application.get_env(:nomad, :cloud_to_migrate) do
    #  :aws -> use Nomad.AWS.Storage, :aws
    #:gcl -> use Nomad.GCL.Storage, :gcl
    #end
  alias Nomad.TasksHelper, as: Helper

  @moduledoc"""
  Task for automatically migrating a remote storage on the chosen cloud
  provider's storage service to another copying every file and storing them in the same
  directory structure as the original storage.
  """

  @shortdoc"Migrate a storage from one service to another copying all the files and directories."

  def run(args) when length(args) == 2 do
    stor_origin = args |> Enum.fetch!(0)
    stor_dest   = args |> Enum.fetch!(1)

    Helper.start_apps_for_adapter(Helper.get_provider)
    Helper.start_apps_for_adapter(Application.get_env(:nomad, :cloud_to_migrate))

    files = stor_origin
    |> Nomad.Storage.list_items

    for file <- files do
      :ok      = Nomad.Storage.get_item(stor_origin, file)
      filename = file |> String.split("/") |> List.last
      # :ok      = put_item(stor_dest, filename, file)
      File.rm! filename
    end
  end
end

