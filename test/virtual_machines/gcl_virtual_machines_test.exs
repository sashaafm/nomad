defmodule Test.Dummy.GCLVirtualMachinesClient do
  use Nomad.GCL.VirtualMachines, :gcl

  def list_virtual_machines_test(state) do
    {:ok, content} = File.read(__DIR__ <> "/response_samples/list_virtual_machine_gcl.rsp")
    content = content |> Poison.decode!

    fn(_a, _b) ->
      case state do
        200 -> {:ok, %{body: content, status_code: 200}}
        555 -> code_555
        :error -> http_error
      end
    end
  end

  def get_virtual_machine_test(state) do
    {:ok, content} = File.read(__DIR__ <> "/response_samples/get_virtual_machine_gcl.rsp")
    content = content |> Poison.decode!

    fn(_a, _b, _c) ->
      case state do
        200    -> {:ok, %{body: content, status_code: 200}}
        555    -> code_555
        :error -> http_error
      end
    end
  end

  def create_virtual_machine_test(state) do
    fn(_a, _b) ->
      case state do
        200    -> {:ok, %{status_code: 200}}
        555    -> code_555
        :error -> http_error
      end
    end
  end

  def delete_virtual_machine_test(state) do
    fn(_a, _b) ->
      case state do
        200    -> {:ok, %{status_code: 200}}
        555    -> code_555
        :error -> http_error
      end
    end
  end

  def start_virtual_machine_test(state) do
    fn(_a, _b) ->
      case state do
        200    -> {:ok, %{status_code: 200}}
        555    -> code_555
        :error -> http_error
      end
    end
  end

  def stop_virtual_machine_test(state) do
    fn(_a, _b) ->
      case state do
        200    -> {:ok, %{status_code: 200}}
        555    -> code_555
        :error -> http_error
      end
    end
  end

  def reboot_virtual_machine_test(state) do
    fn(_a, _b) ->
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
    {:ok, content} = File.read(__DIR__ <> "/response_samples/list_disks_gcl.rsp")
    content = content |> Poison.decode!

    fn(_a, _b) ->
      case state do
        200    -> {:ok, %{body: content, status_code: 200}}
        555    -> code_555
        :error -> http_error
      end
    end
  end

  def get_disk_test(state) do
    {:ok, content} = File.read(__DIR__ <> "/response_samples/get_disk_gcl.rsp")
    content        = content |> Poison.decode!

    fn(_a, _b, _c) ->
      case state do
        200    -> {:ok, %{body: content, status_code: 200}}
        555    -> code_555
        :error -> http_error
      end
    end
  end

  def create_disk_test(state) do
    fn(_a, _b) ->
      case state do
        200    -> {:ok, %{status_code: 200}}
        555    -> code_555
        :error -> http_error
      end
    end
  end

  def create_disk_test(state) do
    fn(_a, _b, _c) ->
      case state do
        200    -> {:ok, %{status_code: 200}}
        555    -> code_555
        :error -> http_error
      end
    end
  end

  def delete_disk_test(state) do
    fn(_a, _b) ->
      case state do
        200    -> {:ok, %{status_code: 200}}
        555    -> code_555
        :error -> http_error
      end
    end
  end

  def attach_disk_test(state) do
    fn(_a, _b, _c) ->
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
      %{body: "{\n \"error\": {\n  \"errors\": [\n   {\n    \"domain\": \"global\",\n    \"reason\": \"notFound\",\n    \"message\": \"Error Message\"\n   }\n  ],\n  \"code\": 555,\n  \"message\": \"Error Message\"\n }\n}\n",
        status_code: 555
      }
    }
  end

  defp http_error, do: {:error, %HTTPoison.Error{id: 123, reason: :reason}}
end

defmodule GCLVirtualMachinesTest do
  use ExUnit.Case
  alias Test.Dummy.GCLVirtualMachinesClient, as: Dummy
  use Nomad.GCL.VirtualMachines, :gcl

  test "list_virtual_machines 200" do
    expected = [{"instance-1", "RUNNING", "f1-micro", "130.211.106.11"}]

    assert expected == list_virtual_machines "dummyRegion", Dummy.list_virtual_machines_test 200
  end

  test "list_virtual_machines 555" do
    expected = get_error_message

    assert expected == list_virtual_machines "dummyRegion", Dummy.list_virtual_machines_test 555
  end

  test "list_virtual_machines error" do
    expected = "reason"

    assert expected == list_virtual_machines "dummyRegion", Dummy.list_virtual_machines_test :error
  end

  test "get_virtual_machine 200" do
    expected = {"dummyInstance", "RUNNING", "f1-micro", "130.211.106.11"}

    assert expected == get_virtual_machine "dummyRegion", "dummyInstance", Dummy.get_virtual_machine_test 200
  end

  test "get_virtual_machine 555" do
    expected = get_error_message

    assert expected == get_virtual_machine "dummyRegion", "dummyInstance", Dummy.get_virtual_machine_test 555
  end

  test "get_virtual_machine error" do
    expected = "reason"

    assert expected == get_virtual_machine "dummyRegion", "dummyInstance", Dummy.get_virtual_machine_test :error
  end

  test "create_virtual_machine 200" do
    expected = :ok

    assert expected == create_virtual_machine "region", "class", "image", true, Dummy.create_virtual_machine_test(200)
  end

  test "create_virtual_machine 555" do
    expected = get_error_message

    assert expected == create_virtual_machine "region", "class", "image", true, Dummy.create_virtual_machine_test(555)
  end

  test "create_virtual_machine error" do
    expected = "reason"

    assert expected == create_virtual_machine "region", "class", "image", true, Dummy.create_virtual_machine_test(:error)
  end

  test "delete_virtual_machine 200" do
    expected = :ok

    assert expected == delete_virtual_machine "region", "instance", Dummy.delete_virtual_machine_test(200)
  end

  test "delete_virtual_machine 555" do
    expected = get_error_message

    assert expected == delete_virtual_machine "region", "instance", Dummy.delete_virtual_machine_test(555)
  end

  test "start_virtual_machine 200" do
    expected = :ok

    assert expected == start_virtual_machine "region", "instance", Dummy.start_virtual_machine_test(200)
  end

  test "start_virtual_machine 555" do
    expected = get_error_message

    assert expected == start_virtual_machine "region", "instance", Dummy.start_virtual_machine_test(555)
  end

  test "start_virtual_machine error" do
    expected = "reason"

    assert expected == start_virtual_machine "region", "instance", Dummy.start_virtual_machine_test(:error)
  end

  test "stop_virtual_machine 200" do
    expected = :ok

    assert expected == stop_virtual_machine "region", "instance", Dummy.stop_virtual_machine_test(200)
  end

  test "stop_virtual_machine 555" do
    expected = get_error_message

    assert expected == stop_virtual_machine "region", "instance", Dummy.stop_virtual_machine_test(555)
  end

  test "stop_virtual_machine error" do
    expected = "reason"

    assert expected == stop_virtual_machine "region", "instance", Dummy.stop_virtual_machine_test(:error)
  end

  test "reboot_virtual_machine 200" do
    expected = :ok

    assert expected == reboot_virtual_machine "region", "instance", Dummy.reboot_virtual_machine_test(200)
  end

  test "reboot_virtual_machine 555" do
    expected = get_error_message

    assert expected == reboot_virtual_machine "region", "instance", Dummy.reboot_virtual_machine_test(555)
  end

  test "reboot_virtual_machine error" do
    expected = "reason"

    assert expected == reboot_virtual_machine "region", "instance", Dummy.reboot_virtual_machine_test(:error)
  end

  test "set_virtual_machine_class 200" do
    expected = :ok

    assert expected == set_virtual_machine_class "region", "instance", "class", Dummy.set_virtual_machine_class_test(200)
  end

  test "set_virtual_machine_class 555" do
    expected = get_error_message

    assert expected == set_virtual_machine_class "region", "instance", "class", Dummy.set_virtual_machine_class_test(555)
  end

  test "set_virtual_machine_class error" do
    expected = "reason"

    assert expected == set_virtual_machine_class "region", "instance", "class", Dummy.set_virtual_machine_class_test(:error)
  end

  test "list_disks 200" do
    expected = [{"instance-1", "10", "debian-8-jessie-v20160511", "READY", "pd-standard"}]

    assert expected == __MODULE__.list_disks "region", Dummy.list_disks_test(200)
  end

  test "list_disks 555" do
    expected = get_error_message

    assert expected == __MODULE__.list_disks "region", Dummy.list_disks_test(555)
  end

  test "list_disks error" do
    expected = "reason"

    assert expected == __MODULE__.list_disks "region", Dummy.list_disks_test(:error)
  end

  test "get_disk 200" do
    expected = {"instance-1", "10", "debian-8-jessie-v20160511", "READY", "pd-standard"}

    assert expected == __MODULE__.get_disk "region", "disk", Dummy.get_disk_test(200)
  end

  test "get_disk 555" do
    expected = get_error_message

    assert expected == __MODULE__.get_disk "region", "disk", Dummy.get_disk_test(555)
  end

  test "get_disk error" do
    expected = "reason"

    assert expected == __MODULE__.get_disk "region", "disk", Dummy.get_disk_test(:error)
  end

  test "delete_disk 200" do
    expected = :ok

    assert expected == __MODULE__.delete_disk "region", "disk", Dummy.delete_disk_test(200)
  end

  test "delete_disk 555" do
    expected = get_error_message

    assert expected == __MODULE__.delete_disk "region", "disk", Dummy.delete_disk_test(555)
  end

  test "delete_disk error" do
    expected = "reason"

    assert expected == __MODULE__.delete_disk "region", "disk", Dummy.delete_disk_test(:error)
  end

  test "attach_disk 200" do
    expected = :ok

    assert expected == __MODULE__.attach_disk "region", "instance", "disk", "device", Dummy.attach_disk_test(200)
  end

  test "attach_disk 555" do
    expected = get_error_message

    assert expected == __MODULE__.attach_disk "region", "instance", "disk", "device", Dummy.attach_disk_test(555)
  end

  test "attach_disk error" do
    expected = "reason"

    assert expected == __MODULE__.attach_disk "region", "instance", "disk", "device", Dummy.attach_disk_test(:error)
  end

  test "detach_disk 200" do
    expected = :ok

    assert expected == __MODULE__.detach_disk "region", "instance", "disk", Dummy.detach_disk_test(200)
  end

  test "detach_disk 555" do
    expected = get_error_message

    assert expected == __MODULE__.detach_disk "region", "instance", "disk", Dummy.detach_disk_test(555)
  end

  test "detach_disk error" do
    expected = "reason"

    assert expected == __MODULE__.detach_disk "region", "instance", "disk", Dummy.detach_disk_test(:error)
  end

  defp get_error_message, do: "555: Error Message"
end
