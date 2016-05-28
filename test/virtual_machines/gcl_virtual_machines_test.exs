defmodule Test.Dummy.GCLVirtualMachinesClient do
  use Nomad.GCL.VirtualMachines, :gcl

  def list_virtual_machines_test(state) do
    fn(_a, _b) ->
      case state do
        200 ->
{:ok,
 %HTTPoison.Response{body: "{\n \"kind\": \"compute#instanceList\",\n \"selfLink\": \"https://www.googleapis.com/compute/v1/projects/vocal-raceway-124010/zones/europe-west1-d/instances\",\n \"id\": \"projects/vocal-raceway-124010/zones/europe-west1-d/instances\",\n \"items\": [\n  {\n   \"kind\": \"compute#instance\",\n   \"id\": \"909193924032362522\",\n   \"creationTimestamp\": \"2016-05-28T09:27:33.635-07:00\",\n   \"zone\": \"https://www.googleapis.com/compute/v1/projects/vocal-raceway-124010/zones/europe-west1-d\",\n   \"status\": \"RUNNING\",\n   \"name\": \"instance-1\",\n   \"description\": \"\",\n   \"tags\": {\n    \"fingerprint\": \"42WmSpB8rSM=\"\n   },\n   \"machineType\": \"https://www.googleapis.com/compute/v1/projects/vocal-raceway-124010/zones/europe-west1-d/machineTypes/f1-micro\",\n   \"canIpForward\": false,\n   \"networkInterfaces\": [\n    {\n     \"network\": \"https://www.googleapis.com/compute/v1/projects/vocal-raceway-124010/global/networks/default\",\n     \"subnetwork\": \"https://www.googleapis.com/compute/v1/projects/vocal-raceway-124010/regions/europe-west1/subnetworks/default-98c87532e4a272cc\",\n     \"networkIP\": \"10.132.0.2\",\n     \"name\": \"nic0\",\n     \"accessConfigs\": [\n      {\n       \"kind\": \"compute#accessConfig\",\n       \"type\": \"ONE_TO_ONE_NAT\",\n       \"name\": \"External NAT\",\n       \"natIP\": \"130.211.106.11\"\n      }\n     ]\n    }\n   ],\n   \"disks\": [\n    {\n     \"kind\": \"compute#attachedDisk\",\n     \"index\": 0,\n     \"type\": \"PERSISTENT\",\n     \"mode\": \"READ_WRITE\",\n     \"source\": \"https://www.googleapis.com/compute/v1/projects/vocal-raceway-124010/zones/europe-west1-d/disks/instance-1\",\n     \"deviceName\": \"instance-1\",\n     \"boot\": true,\n     \"autoDelete\": true,\n     \"licenses\": [\n      \"https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/licenses/ubuntu-1604-xenial\"\n     ],\n     \"interface\": \"SCSI\"\n    }\n   ],\n   \"metadata\": {\n    \"kind\": \"compute#metadata\",\n    \"fingerprint\": \"7IGWSVjKT5M=\"\n   },\n   \"serviceAccounts\": [\n    {\n     \"email\": \"google-cloud-storage@vocal-raceway-124010.iam.gserviceaccount.com\",\n     \"scopes\": [\n      \"https://www.googleapis.com/auth/cloud-platform\"\n     ]\n    }\n   ],\n   \"selfLink\": \"https://www.googleapis.com/compute/v1/projects/vocal-raceway-124010/zones/europe-west1-d/instances/instance-1\",\n   \"scheduling\": {\n    \"onHostMaintenance\": \"MIGRATE\",\n    \"automaticRestart\": true,\n    \"preemptible\": false\n   },\n   \"cpuPlatform\": \"Intel Haswell\"\n  }\n ]\n}\n",
  headers: [{"Expires", "Sat, 28 May 2016 16:28:07 GMT"},
   {"Date", "Sat, 28 May 2016 16:28:07 GMT"},
   {"Cache-Control", "private, max-age=0, must-revalidate, no-transform"},
   {"ETag", "\"gX2CJOt7BbRCBP6GcIEKUc2LWGY/FXssKwHtcxoSIPWnzhZw6vH5DGs\""},
   {"Vary", "Origin"}, {"Vary", "X-Origin"},
   {"Content-Type", "application/json; charset=UTF-8"},
   {"X-Content-Type-Options", "nosniff"}, {"X-Frame-Options", "SAMEORIGIN"},
   {"X-XSS-Protection", "1; mode=block"}, {"Content-Length", "2359"},
   {"Server", "GSE"}, {"Alternate-Protocol", "443:quic"},
   {"Alt-Svc",
    "quic=\":443\"; ma=2592000; v=\"34,33,32,31,30,29,28,27,26,25\""}],
  status_code: 200}}

        555 -> code_555
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
    expected = "555: Error Message"

    assert expected == list_virtual_machines "dummyRegion", Dummy.list_virtual_machines_test 555
  end

  test "list_virtual_machines error" do
    expected = "reason"

    assert expected == list_virtual_machines "dummyRegion", Dummy.list_virtual_machines_test :error 
  end
end
