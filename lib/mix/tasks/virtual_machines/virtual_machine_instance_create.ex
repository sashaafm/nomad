defmodule Mix.Tasks.Nomad.VirtualMachineInstance.Create do
  use Mix.Task

  @moduledoc"""
  Task for automatically creating a remote virtual machine instance on a
  pre-determined cloud provider. The instace creation is done through the
  cloud provider's API and restricted to the common options and operations
  that are offered across APIs.

  More in depth creation of instances with other options and configurations
  not provided in here must be done in the cloud provider's console or by
  other means.
  """

  @shortdoc"Create a virtual machine on the chosen cloud provider's infrastructure service."

  @doc"""
  Runs the task for the chosen cloud provider. The shell prompts and necessary
  input parameters change with the chosen provider.
  """
  @spec run(args :: [binary] | []) :: binary
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

