defmodule Test.Dummy.GCLStorageClient do
  use Nomad.GCL.Storage, :gcl

  def list_buckets_test(state) do 
    fn ->
      case state do 
        200 ->
          {:ok, %{
            body: """
            <name>first_bucket</name>
            <name>second_bucket</name>
            """,
            status_code: 200
          }}
        555 -> code_555

        :error -> {:error, http_error}
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

  defp http_error, do: %HTTPoison.Error{id: 123, reason: :reason}
end

defmodule GclStorageTest do
  use ExUnit.Case
  alias Test.Dummy.GCLStorageClient, as: Dummy
  use Nomad.GCL.Storage, :gcl

  test "list_storages 200" do 
    expected = ["first_bucket", "second_bucket"]

    assert expected == list_storages Dummy.list_buckets_test 200
  end

  test "list_storages 555" do 
    expected = "555: Error message"

    assert expected == list_storages Dummy.list_buckets_test 555
  end

  test "list_storages error" do 
    expected = "reason"

    assert expected == list_storages Dummy.list_buckets_test :error
  end
  
end