defmodule Mix.Tasks.Nomad.VirtualMachineInstance.Create do
  use Mix.Task

  @moduledoc"""

  """

  @shortdoc"""
  """

  def run(args) do
    case Application.get_env(:nomad, :cloud_provider) do
      :aws ->
        Application.ensure_all_started(:ex_aws)
        Application.ensure_all_started(:httpoison)

        create_instance_aws args
      :gcl ->
        Application.ensure_all_started(:httpoison)
        Application.ensure_all_started(:goth)
        Application.ensure_all_started(:gcloudex)

        create_instance_gcl args
    end
  end

  defp create_instance_aws(args) do
    zone  = Mix.Shell.IO.prompt("Insert the desired zone for the instance " <>
      "(#{Enum.join(Nomad.VirtualMachines.list_regions, ", ")}): ") |> String.rstrip
    class = Mix.Shell.IO.prompt("Insert the instance class " <> 
      "(#{Enum.join(Nomad.VirtualMachines.list_classes, ", ")}): ") |> String.rstrip
    image = Mix.Shell.IO.prompt("Insert the image (AMI) to use: ") |> String.rstrip
    del   = Mix.Shell.IO.yes?("Set auto deletion for the instance?")

    Mix.Shell.IO.info("\n")
    Mix.Shell.IO.info("########################### SUMMARY #########################\n")

    summary = "The instance will be created with the following settings:\n"
    <> "Zone:        #{zone}\n"
    <> "Class:       #{class}\n"
    <> "Image:       #{image}\n"
    <> "Auto Delete: #{del}\n"
    <> "Do you confirm?\n"

    if Mix.Shell.IO.yes?(summary) do
      result = Nomad.VirtualMachines.create_virtual_machine zone, class, image, del

      case result do
        :ok -> Mix.Shell.IO.info("The instance has been created successfully.")
        msg -> Mix.Shell.IO.info("A problem has occurred: \n#{msg}")
      end
    else
      create_instance_aws(args)
    end
  end

  defp create_instance_gcl(args) do
    zone  = Mix.Shell.IO.prompt("Insert the desired zone for the instance " <>
      "(#{Enum.join(Nomad.VirtualMachines.list_regions, ", ")}): ") |> String.rstrip
    class = Mix.Shell.IO.prompt("Insert the instance class " <> 
     "(#{Enum.join(Nomad.VirtualMachines.list_classes, ", ")}): ") |> String.rstrip
    image = Mix.Shell.IO.prompt("Insert the image to use: ") |> String.rstrip
    del   = Mix.Shell.IO.yes?("Set auto deletion for the instance?")

    Mix.Shell.IO.info("\n")
    Mix.Shell.IO.info("########################### SUMMARY #########################\n")

    summary = "The instance will be created with the following settings:\n"
    <> "Zone:        #{zone}\n"
    <> "Class:       #{class}\n"
    <> "Image:       #{image}\n"
    <> "Auto Delete: #{del}\n"
    <> "Do you confirm?\n"

    if Mix.Shell.IO.yes?(summary) do
      result = Nomad.VirtualMachines.create_virtual_machine zone, class, image, del

      case result do
        :ok -> Mix.Shell.IO.info("The instance has been create successfully.")
        msg -> Mix.Shell.IO.info("A problem has occurred: \n#{msg}")
      end
    else
      create_instance_gcl(args)
    end
  end
end

