defmodule Dummy.Test.AwsSqlClient do
  use Nomad.AWS.SQL, :aws

  def describe_db_instances_test(state) do
    fn ->
      case state do
        200     ->
          file = File.read! __DIR__ <> "/aws_describe_db_instances_response.xml"
          {:ok, %{status_code: 200, body: file}}
        555    -> code_555
        :error -> http_error
      end
    end
  end

  def get_instance_test(state) do
    fn (_instance) ->
      case state do
        200    ->
          file = File.read! __DIR__ <> "/aws_describe_db_instances_response.xml"
          {:ok, %{status_code: 200, body: file}}
        555    -> code_555
        :error -> http_error
      end
    end
  end

  def create_db_instance_test(state) do
    fn (_a, _b, _c, _d, _e, _f, _g) ->
      case state do
        200    -> {:ok, %{status_code: 200, body: ""}}
        555    -> code_555
        :error -> http_error
      end
    end
  end

  def delete_db_instance_test(state) do
    fn (_instance) ->
      case state do
        200    -> {:ok, %{status_code: 200, body: ""}}
        555    -> code_555
        :error -> http_error
      end
    end
  end

  def reboot_db_instance_test(state) do
    fn (_instance) ->
      case state do
        200    -> {:ok, %{status_code: 200, body: ""}}
        555    -> code_555
        :error -> http_error
      end
    end
  end

  def list_databases_test(state) do
    fn (_instance) ->
      case state do
        200    ->
          {
            :ok,
            %{
              status_code: 200,
              body: "<DbName>ABC</DbName><DbName>DEF</DbName>"
            }
          }
        555    -> code_555
        :error -> http_error
      end
    end
  end

  def get_instance_address_test(state) do
    fn (_instance) ->
      case state do
        200    -> {:a, :b, "address", :c, :d}
        :error -> "Message"
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

defmodule AwsSqlTest do
  use ExUnit.Case
  alias Dummy.Test.AwsSqlClient, as: Dummy
  use Nomad.AWS.SQL, :aws

  test "list_instances 200" do
    expected = [
      {
        "some-instance",
        "us-east-1c",
        "some-instance.cm8d08jcynwa.us-east-1.rds.amazonaws.com",
        "available",
        "5"}
    ]

    assert expected == list_instances Dummy.describe_db_instances_test 200
  end

  test "list_instances 555" do
    expected = other_code

    assert expected == list_instances Dummy.describe_db_instances_test 555
  end

  test "list_instances error" do
    expected = "reason"

    assert expected == list_instances Dummy.describe_db_instances_test :error
  end

  test "get_instance 200" do
    expected = {
      "some-instance",
      "us-east-1c",
      "some-instance.cm8d08jcynwa.us-east-1.rds.amazonaws.com",
      "available",
      "5"}

    assert expected == get_instance "some-instance", Dummy.get_instance_test 200
  end

  test "get_instance 555" do
    expected = other_code

    assert expected == get_instance "some-instance", Dummy.get_instance_test 555
  end

  test "get_instance error" do
    expected = "reason"

    assert expected == get_instance "some-instance", Dummy.get_instance_test :error
  end

  test "insert_instance 200" do
    expected = :ok

    assert expected == insert_instance(
      :a,
      %{storage: "abc", engine: "def"},
      {:c, :f},
      {:d, :e},
      [],
      Dummy.create_db_instance_test(200))
  end

  test "insert_instance 555" do
    expected = other_code

    assert expected == insert_instance(
      :a,
      %{storage: "abc", engine: "def"},
      {:c, :f},
      {:d, :e},
      [],
      Dummy.create_db_instance_test(555))
  end

  test "insert_instance error" do
    expected = "reason"

    assert expected == insert_instance(
      :a,
      %{storage: "abc", engine: "def"},
      {:c, :f},
      {:d, :e},
      [],
      Dummy.create_db_instance_test(:error))
  end

  test "delete_instance 200" do
    expected = :ok

    assert expected == delete_instance "abc", Dummy.delete_db_instance_test(200)
  end

  test "delete_instance 555" do
    expected = other_code

    assert expected == delete_instance "abc", Dummy.delete_db_instance_test(555)
  end

  test "delete_instance error" do
    expected = "reason"

    assert expected == delete_instance "abc", Dummy.delete_db_instance_test(:error)
  end

  test "restart_instance 200" do
    expected = :ok

    assert expected == restart_instance "abc", Dummy.reboot_db_instance_test(200)
  end

  test "restart_instance 555" do
    expected = other_code

    assert expected == restart_instance "abc", Dummy.reboot_db_instance_test(555)
  end

  test "restart_instance error" do
    expected = "reason"

    assert expected == restart_instance "abc", Dummy.reboot_db_instance_test(:error)
  end

  test "list_databases 200" do
    expected = ["ABC", "DEF"]

    assert expected == list_databases "abc", Dummy.list_databases_test(200)
  end

  test "list_databases 555" do
    expected = other_code

    assert expected == list_databases "abc", Dummy.list_databases_test(555)
  end

  test "list_databases error" do
    expected = "reason"

    assert expected == list_databases "abc", Dummy.list_databases_test(:error)
  end

  test "list_classes" do
    expected = ["db.t1.micro",    "db.m1.small",   "db.m1.medium",  "db.m1.large",
     "db.m1.xlarge",   "db.m2.xlarge",  "db.m2.2xlarge", "db.m2.4xlarge",
     "db.m3.medium",   "db.m3.large",   "db.m3.xlarge",  "db.m3.2xlarge",
     "db.m4.large",    "db.m4.xlarge",  "db.m4.2xlarge", "db.m4.4xlarge",
     "db.m4.10xlarge", "db.r3.large",   "db.r3.xlarge",  "db.r3.2xlarge",
     "db.r3.4xlarge",  "db.r3.8xlarge", "db.t2.micro",   "db.t2.small",
     "db.t2.medium",   "db.t2.large"]

     assert expected == list_classes
  end

  test "get_instance_address 200" do
    expected = "address"

    assert expected == get_instance_address "ABC", Dummy.get_instance_address_test(200)
  end

  test "get_instance_address error" do
    expected = "Message"

    assert expected == get_instance_address "ABC", Dummy.get_instance_address_test(:error)
  end


  defp other_code, do: "555: Error message"
end
