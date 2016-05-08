defmodule Dummy.Test.GclSqlClient do
  use Nomad.GCL.SQL, :gcl

  def list_instances_test(state) do 
    fn ->
      case state do 
        200    -> 
          {
            :ok,
            %{
              status_code: 200,
              body: 
              %{
                "items" => 
                [
                  %{
                    "name"        => "abc", 
                    "region"      => "region_a", 
                    "state"       => "OK", 
                    "maxDiskSize" => "1"
                  },
                  %{
                    "name"        => "def",
                    "region"      => "region_b",
                    "state"       => "FAIL",
                    "ipAdresses"  => ["address_1", "address_2"],
                    "maxDiskSize" => "2"
                  }
                ]
              } 
              |> Poison.encode!
            }
          }
        555    -> code_555
        :error -> http_error
      end
    end
  end

  def get_instance_test(state) do 
    fn (_instance) ->
      case state do 
        200    ->
          {
            :ok, 
            %{
              status_code: 200, 
              body: Poison.encode!(
                %{
                  "name"        => "abc", 
                  "region"      => "region_a", 
                  "state"       => "OK", 
                  "maxDiskSize" => "1"
                })
              }
            } 
        555    -> code_555
        :error -> http_error
      end
    end
  end

  def insert_instance_test(state) do 
    fn (_instance, _opts, _settings, _tier) ->
      case state do 
        200    -> {:ok, %{status_code: 200, body: ""}}
        555    -> code_555
        :error -> http_error
      end
    end
  end

  def delete_instance_test(state) do 
    fn (_instance) ->
      case state do 
        200    -> {:ok, %{status_code: 200, body: ""}}
        555    -> code_555
        :error -> http_error
      end
    end
  end

  def restart_instance_test(state) do 
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
              body: Poison.encode!(
                %{
                  "items" => [
                    %{"name" => "ABC"}, 
                    %{"name" => "DEF"}
                  ]
                })
            }
          }

        555    -> code_555
        :error -> http_error
      end
    end
  end

  def list_classes_test(state) do 
    fn ->
      case state do 
        200    ->
          {
            :ok,
            %{
              status_code: 200,
              body: Poison.encode!(
                %{
                  "items" => [
                    %{"tier" => "tier_a"},
                    %{"tier" => "tier_b"}
                  ]
                })
            }
          }

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

defmodule GclSqlTest do 
  use ExUnit.Case
  alias Dummy.Test.GclSqlClient, as: Dummy
  use Nomad.GCL.SQL, :gcl

  test "list_instances 200" do 
    expected = [
      {"abc", "region_a", "No Address", "OK", 1.0e-9},
      {"def", "region_b", "No Address", "FAIL", 2.0e-9}
    ]

    assert expected == list_instances Dummy.list_instances_test(200)
  end

  test "list_instances 555" do 
    expected = other_code

    assert expected == list_instances Dummy.list_instances_test(555)
  end

  test "list_instances error" do 
    expected = "reason"

    assert expected == list_instances Dummy.list_instances_test(:error)
  end

  test "get_instance 200" do
    expected = {"abc", "region_a", "No Address", "OK", 1.0e-9}

    assert expected == get_instance :a, Dummy.get_instance_test(200)    
  end

  test "get_instance 555" do 
    expected = other_code

    assert expected == get_instance :a, Dummy.get_instance_test(555)
  end

  test "get_instance error" do
    expected = "reason"

    assert expected == get_instance :a, Dummy.get_instance_test(:error)
  end

  # test "insert_instance 200" do 
  #   expected = :ok

  #   assert expected == insert_instance "instance", %{"abc" => 123}, {"region", "tier"}, {"user", "pw"}, [], Dummy.insert_instance_test(200)
  # end

  test "delete_instance 200" do 
    expected = :ok

    assert expected == delete_instance :a, Dummy.delete_instance_test(200)
  end

  test "delete_instance 555" do 
    expected = other_code

    assert expected == delete_instance :a, Dummy.delete_instance_test(555)
  end

  test "delete_instance error" do 
    expected = "reason"

    assert expected == delete_instance :a, Dummy.delete_instance_test(:error)
  end

  test "restart_instance 200" do
    expected = :ok

    assert expected == restart_instance :a, Dummy.restart_instance_test(200)
  end

  test "restart_instance 555" do
    expected = other_code

    assert expected == restart_instance :a, Dummy.restart_instance_test(555)
  end

  test "restart_instance error" do
    expected = "reason"

    assert expected == restart_instance :a, Dummy.restart_instance_test(:error)
  end    

  test "list_databases 200" do 
    expected = ["ABC", "DEF"]

    assert expected == list_databases :a, Dummy.list_databases_test(200)
  end

  test "list_databases 555" do 
    expected = other_code

    assert expected == list_databases :a, Dummy.list_databases_test(555)
  end  

  test "list_databases error" do 
    expected = "reason"

    assert expected == list_databases :a, Dummy.list_databases_test(:error)
  end  

  test "list_classes 200" do 
    expected = ["tier_a", "tier_b"]

    assert expected == list_classes Dummy.list_classes_test(200)
  end

  test "list_classes 555" do 
    expected = other_code

    assert expected == list_classes Dummy.list_classes_test(555)
  end  

  test "list_classes error" do 
    expected = "reason"

    assert expected == list_classes Dummy.list_classes_test(:error)
  end    

  defp other_code, do: "555: Error message"  
end