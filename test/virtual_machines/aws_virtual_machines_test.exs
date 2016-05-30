defmodule Test.Dummy.AWSVirtualMachinesClient do
  use Nomad.AWS.VirtualMachines, :aws

  def list_virtual_machines_test(state) do
    {:ok, content} = File.read(__DIR__ <> "/response_samples/list_virtual_machines_aws.rsp")
    content        = Poison.decode!(content)

    fn (_a) ->
      case state do
        200    -> {:ok, %{body: content, status_code: 200}}
        555    -> code_555
        :error -> http_error
      end
    end
  end

  def get_virtual_machine_test(region, state) do
    apply(fn a, b -> dummy_list_vms(a, b) end, [region, state])
  end

  defp dummy_list_vms(region, state) do
    case state do
      200 -> list_virtual_machines(region, list_virtual_machines_test(200))
    end
  end

  def create_virtual_machine_test(state) do
    fn (_a, _b, _c, _d, _f) ->
      case state do
        200    -> {:ok, %{status_code: 200}}
        555    -> code_555
        :error -> http_error
      end
    end
  end

  def delete_virtual_machine_test(state) do
    fn (_a, _b) ->
      case state do
        200    -> {:ok, %{status_code: 200}}
        555    -> code_555
        :error -> http_error
      end
    end
  end

  def start_virtual_machine_test(state) do
    fn (_a, _b) ->
      case state do
        200    -> {:ok, %{status_code: 200}}
        555    -> code_555
        :error -> http_error
      end
    end
  end

  def stop_virtual_machine_test(state) do
    fn (_a, _b) ->
      case state do
        200    -> {:ok, %{status_code: 200}}
        555    -> code_555
        :error -> http_error
      end
    end
  end

  def reboot_virtual_machine_test(state) do
    fn (_a, _b) ->
      case state do
        200    -> {:ok, %{status_code: 200}}
        555    -> code_555
        :error -> http_error
      end
    end
  end

  def set_virtual_machine_class_test(state) do
    fn(_a, _b, _c) ->
      case state do
        200    -> {:ok, %{status_code: 200}}
        555    -> code_555
        :error -> http_error
      end
    end
  end

  def list_disks_test(state) do
    {:ok, content} = File.read(__DIR__ <> "/response_samples/list_disks_aws.rsp")
    content        = Poison.decode!(content)

    fn(_a) ->
      case state do
        200    -> {:ok, %{body: content, status_code: 200}}
        555    -> code_555
        :error -> http_error
      end
    end
  end

  def delete_disk_test(state) do
    fn (_a, _b) ->
      case state do
        200    -> {:ok, %{status_code: 200}}
        555    -> code_555
        :error -> http_error
      end
    end
  end

  def attach_disk_test(state) do
    fn(_a, _b, _c, _d) ->
      case state do
        200    -> {:ok, %{status_code: 200}}
        555    -> code_555
        :error -> http_error
      end
    end
  end

  def detach_disk_test(state) do
    fn(_a, _b, _c) ->
      case state do
        200    -> {:ok, %{status_code: 200}}
        555    -> code_555
        :error -> http_error
      end
    end
  end

  defp code_555 do
    {
      :ok,
      %{body: """
      <message>Error message</message>
      """,
        status_code: 555
      }
    }
  end

  defp http_error, do: {:error, %HTTPoison.Error{id: 123, reason: :reason}}
end

defmodule AWSVirtualMachinesTest do
  use ExUnit.Case
  alias Test.Dummy.AWSVirtualMachinesClient, as: Dummy
  use Nomad.AWS.VirtualMachines, :aws

  test "list_virtual_machines 200" do
    expected = [{"i-28c002b4", "running", "54.172.208.68", "t2.micro"}]

    assert expected == list_virtual_machines "us-east-1", Dummy.list_virtual_machines_test(200)
  end

  test "list_virtual_machines 555" do
    expected = get_error_message

    assert expected == list_virtual_machines "us-east-1", Dummy.list_virtual_machines_test(555)
  end

  test "list_virtual_machines error" do
    expected = "reason"

    assert expected == list_virtual_machines "us-east-1", Dummy.list_virtual_machines_test(:error)
  end

  test "get_virtual_machine 200" do
    expected = {"i-28c002b4", "running", "54.172.208.68", "t2.micro"}

    assert expected ==
      get_virtual_machine(
        200,
        "i-28c002b4",
        Dummy.get_virtual_machine_test("someregion", 200))
  end

 # test "get_virtual_machine 555" do
 #   expected = get_error_message
 #
 #   assert expected == get_virtual_machine "us-east-1", Dummy.list_virtual_machines_test(555)
 # end

  test "create_virtual_machine 200" do
    expected = :ok

     assert expected == create_virtual_machine "us-east-1c", "class", "image", true, Dummy.create_virtual_machine_test(200)
  end

  test "create_virtual_machine 555" do
    expected = get_error_message

    assert expected == create_virtual_machine "us-east-1c", "class", "image", true, Dummy.create_virtual_machine_test(555)
  end

  test "create_virtual_machine error" do
    expected = "reason"

    assert expected == create_virtual_machine "us-east-1c", "class", "image", true, Dummy.create_virtual_machine_test(:error)
  end

  test "delete_virtual_machine 200" do
    expected = :ok

    assert expected == delete_virtual_machine "us-east-1", "instance", Dummy.delete_virtual_machine_test(200)
  end

  test "delete_virtual_machine 555" do
    expected = get_error_message

    assert expected == delete_virtual_machine "us-east-1", "instance", Dummy.delete_virtual_machine_test(555)
  end

  test "delete_virtual_machine error" do
    expected = "reason"

    assert expected == delete_virtual_machine "us-east-1", "instance", Dummy.delete_virtual_machine_test(:error)
  end

  test "start_virtual_machine 200" do
    expected = :ok

    assert expected == start_virtual_machine "us-east-1", "instance", Dummy.start_virtual_machine_test(200)
  end

  test "start_virtual_machine 555" do
    expected = get_error_message

    assert expected == start_virtual_machine "us-east-1", "instance", Dummy.start_virtual_machine_test(555)
  end

  test "start_virtual_machine error" do
    expected = "reason"

    assert expected == start_virtual_machine "us-east-1", "instance", Dummy.start_virtual_machine_test(:error)
  end

  test "stop_virtual_machine 200" do
    expected = :ok

    assert expected == stop_virtual_machine "us-east-1", "instance", Dummy.stop_virtual_machine_test(200)
  end

  test "stop_virtual_machine 555" do
    expected = get_error_message

    assert expected == stop_virtual_machine "us-east-1", "instance", Dummy.stop_virtual_machine_test(555)
  end

  test "stop_virtual_machine error" do
    expected = "reason"

    assert expected == stop_virtual_machine "us-east-1", "instance", Dummy.stop_virtual_machine_test(:error)
  end

  test "reboot_virtual_machine 200" do
    expected = :ok

    assert expected == reboot_virtual_machine "us-east-1", "instance", Dummy.reboot_virtual_machine_test(200)
  end

  test "reboot_virtual_machine 555" do
    expected = get_error_message

    assert expected == reboot_virtual_machine "us-east-1", "instance", Dummy.reboot_virtual_machine_test(555)
  end

  test "reboot_virtual_machine error" do
    expected = "reason"

    assert expected == reboot_virtual_machine "us-east-1", "instance", Dummy.reboot_virtual_machine_test(:error)
  end

  test "set_virtual_machine_class 200" do
    expected = :ok

    assert expected == set_virtual_machine_class "us-east-1", "instance", "class", Dummy.set_virtual_machine_class_test(200)
  end

  test "set_virtual_machine_class 555" do
    expected = get_error_message

    assert expected == set_virtual_machine_class "us-east-1", "instance", "class", Dummy.set_virtual_machine_class_test(555)
  end

  test "set_virtual_machine_class error" do
    expected = "reason"

    assert expected == set_virtual_machine_class "us-east-1", "instance", "class", Dummy.set_virtual_machine_class_test(:error)
  end

  test "list_disks 200" do
    expected = [
      {"vol-032798a6", "8", "snap-a9b8c94e", "available", "gp2"},
      {"vol-a9cf5879", "8", "snap-a9b8c94e", "in-use", "gp2"}
    ]

    assert expected == list_disks "us-east-1", Dummy.list_disks_test(200)
  end

  test "list_disks 555" do
    expected = get_error_message

    assert expected == list_disks "us-east-1", Dummy.list_disks_test(555)
  end

  test "list_disks error" do
    expected = "reason"

    assert expected == list_disks "us-east-1", Dummy.list_disks_test(:error)
  end

  test "delete_disk 200" do
    expected = :ok

    assert expected == delete_disk "us-east-1", "instance", Dummy.delete_disk_test(200)
  end

  test "delete_disk 555" do
    expected = get_error_message

    assert expected == delete_disk "us-east-1", "instance", Dummy.delete_disk_test(555)
  end

  test "delete_disk error" do
    expected = "reason"

    assert expected == delete_disk "us-east-1", "instance", Dummy.delete_disk_test(:error)
  end

  test "attach_disk 200" do
    expected = :ok

    assert expected == attach_disk "us-east-1", "instance", "disk", "device", Dummy.attach_disk_test(200)
  end

  test "attach_disk 555" do
    expected = get_error_message

    assert expected == attach_disk "us-east-1", "instance", "disk", "device", Dummy.attach_disk_test(555)
  end

  test "attach_disk error" do
    expected = "reason"

    assert expected == attach_disk "us-east-1", "instance", "disk", "device", Dummy.attach_disk_test(:error)
  end

  test "detach_disk 200" do
    expected = :ok

    assert expected == detach_disk "us-east-1", "instance", "disk", Dummy.detach_disk_test(200)
  end

  test "detach_disk 555" do
    expected = get_error_message

    assert expected == detach_disk "us-east-1", "instance", "disk", Dummy.detach_disk_test(555)
  end

  test "detach_disk error" do
    expected = "reason"

    assert expected == detach_disk "us-east-1", "instance", "disk", Dummy.detach_disk_test(:error)
  end
  defp get_error_message, do: "555: Error message"
end
