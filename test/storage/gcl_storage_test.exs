defmodule Test.Dummy.GCLStorageClient do

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
        :empty ->
          {:ok, %{
            body: """
            """,
            status_code: 200
          }}          
        555 -> code_555

        :error -> http_error
      end
    end
  end

  def create_bucket_test(state) do 
    fn (_bucket, _region, _class) ->
      case state do 
        200    -> {:ok, %{status_code: 200}}
        555    -> code_555
        :error -> http_error
      end
    end
  end

  def put_object_test(state) do 
    fn (_bucket, _filepath, _storage_path) ->
      case state do 
        200    -> {:ok, %{status_code: 200}}
        555    -> code_555
        :error -> http_error
      end
    end
  end

  def delete_object_test(state) do
    fn (_bucket, _object) ->
      case state do 
        204    -> {:ok, %{status_code: 204}}
        555    -> code_555
        :error -> http_error
      end
    end
  end

  def get_object_test(state) do 
    fn (_bucket, _object) ->
      case state do 
        200    -> {:ok, %{status_code: 200, body: "abc"}}
        555    -> code_555
        :error -> http_error
      end
    end
  end

  def get_object_acl_test(state) do 
    fn (_bucket, _object) ->
      case state do 
        200    -> 
          {
            :ok, 
            %{
              status_code: 200, 
              body: acl_body
            }
          }
        555    -> code_555
        :error -> http_error
      end
    end    
  end

  def list_objects_test(state) do 
    fn (_bucket) ->
      case state do 
        200    -> 
          {
            :ok, 
            %{
              status_code: 200, 
              body: """
              <Key>ABC</Key>
              <Key>DEF</Key>
              <Key>XYZ</Key>
              """
            }
          }
        555    -> code_555
        :error -> http_error
      end
    end    
  end

  def delete_bucket_test(state) do 
    fn (_bucket) ->
      case state do 
        204    -> {:ok, %{status_code: 204}}
        555    -> code_555
        :error -> http_error
      end
    end
  end

  def get_bucket_region_test(state) do 
    fn (_bucket) ->
      case state do 
        200    -> 
          {
            :ok,
            %{
              status_code: 200,
              body: """
              <LocationConstraint>Some Region</LocationConstraint>
              """
            }
          }
        555    -> code_555
        :error -> http_error
      end
    end
  end

  def get_bucket_class_test(state) do 
    fn (_bucket) ->
      case state do 
        200    -> 
          {
            :ok,
            %{
              status_code: 200,
              body: """
              <StorageClass>Some Class</StorageClass>
              """
            }
          }
        555    -> code_555
        :error -> http_error
      end
    end
  end  

  def get_bucket_acl_test(state) do
    fn (_bucket) ->
      case state do 
        200    ->
          {
            :ok,
            %{
              status_code: 200,
              body: acl_body
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

  defp acl_body do 
    """
    <?xml version='1.0' encoding='UTF-8'?>
    <AccessControlList>
      <Owner>
        <ID>00b4903a97951ac13429af116a9874587b212fd507d682097b3140e50f72406e</ID>
      </Owner>
      <Entries>
        <Entry>
          <Scope type='GroupById'>
            <ID>00b4903a979d00a888b29e9968887baaefca546bc5f81b377fc6f3ecdfb8ae5a</ID>
            <Name>User A</Name>
          </Scope>
          <Permission>Type A</Permission>
        </Entry>
        <Entry>
          <Scope type='GroupById'>
            <ID>00b4903a97db3e11424d39a56eb251c792deae6866074fd580f5507d3825a487</ID>
            <Name>User B</Name>
          </Scope>
          <Permission>Type A</Permission>
        </Entry>
        <Entry>
          <Scope type='GroupById'>
            <ID>00b4903a97dc2c9389ba3ca26749ccd3d2913dbbb8f8800ab5d9835b258b8375</ID>
            <Name>User C</Name>
          </Scope>
          <Permission>Type B</Permission>
        </Entry>
        <Entry>
          <Scope type='UserById'>
            <ID>User D</ID>
          </Scope>
          <Permission>Type A</Permission>
        </Entry>
      </Entries>
    </AccessControlList>"
    """
  end
end

defmodule GCLStorageTest do
  use ExUnit.Case
  alias Test.Dummy.GCLStorageClient, as: Dummy
  import Nomad.GCL.Storage

  test "list_storages 200" do 
    expected = ["first_bucket", "second_bucket"]

    assert expected == list_storages Dummy.list_buckets_test 200
  end

  test "list_storages empty" do 
    expected = []

    assert expected == list_storages Dummy.list_buckets_test :empty
  end  

  test "list_storages 555" do 
    expected = other_code

    assert expected == list_storages Dummy.list_buckets_test 555
  end

  test "list_storages error" do 
    expected = "reason"

    assert expected == list_storages Dummy.list_buckets_test :error
  end

  test "create_storage 200" do 
    expected = :ok

    assert expected == create_storage(:a, :b, :c, Dummy.create_bucket_test(200))
  end

  test "create_storage 555" do 
    expected = other_code

    assert expected == create_storage :a, :b, :c, Dummy.create_bucket_test 555
  end  

  test "create_storage error" do 
    expected = "reason"

    assert expected == create_storage :a, :b, :c, Dummy.create_bucket_test :error
  end

  test "put_item 200" do 
    expected = :ok

    assert expected == put_item :a, :b, :c, Dummy.put_object_test(200)
  end

  test "put_item 555" do 
    expected = other_code

    assert expected == put_item :a, :b, :c, Dummy.put_object_test(555)
  end

  test "put_item error" do 
    expected = "reason"

    assert expected == put_item :a, :b, :c, Dummy.put_object_test(:error)
  end

  test "delete_item 204" do 
    expected = :ok

    assert expected == delete_item :a, :b, Dummy.delete_object_test(204)
  end

  test "delete_item 555" do 
    expected = other_code

    assert expected == delete_item :a, :b, Dummy.delete_object_test(555)
  end

  test "delete_item error" do 
    expected = "reason"

    assert expected == delete_item :a, :b, Dummy.delete_object_test(:error)
  end    

  test "get_item 200" do 
    expected = :ok

    assert expected == get_item("abc", "def", Dummy.get_object_test(200))
    :ok = File.rm "def"
  end

  test "get_item 555" do 
    expected = other_code

    assert expected == get_item("abc", "def", Dummy.get_object_test(555))
  end

  test "get_item error" do 
    expected = "reason"

    assert expected == get_item("abc", "def", Dummy.get_object_test(:error))
  end  

  test "get_item_acl 200" do 
    expected = [{"User A", "Type A"}, 
                {"User B", "Type A"}, 
                {"User C", "Type B"}, 
                {"User D", "Type A"}]

    assert expected == get_item_acl(:a, :b, Dummy.get_object_acl_test(200))
  end

  test "get_item_acl 555" do 
    expected = other_code

    assert expected == get_item_acl(:a, :b, Dummy.get_object_acl_test(555))
  end

  test "get_item_acl error" do 
    expected = "reason"

    assert expected == get_item_acl(:a, :b, Dummy.get_object_acl_test(:error))
  end  

  test "list_items 200" do 
    expected = ["ABC", "DEF", "XYZ"]

    assert expected == list_items :a, Dummy.list_objects_test(200)
  end

  test "list_items 555" do 
    expected = other_code

    assert expected == list_items :a, Dummy.list_objects_test(555)
  end  

  test "list_items error" do 
    expected = "reason"

    assert expected == list_items :a, Dummy.list_objects_test(:error)
  end    

  test "delete_storage 204" do 
    expected = :ok

    assert expected == delete_storage :a, Dummy.delete_bucket_test(204)
  end

  test "delete_storage 555" do 
    expected = other_code

    assert expected == delete_storage :a, Dummy.delete_bucket_test(555)
  end

  test "delete_storage error" do 
    expected = "reason"

    assert expected == delete_storage :a, Dummy.delete_bucket_test(:error)
  end  

  test "get_storage_region 200" do 
    expected = "Some Region"

    assert expected == get_storage_region :a, Dummy.get_bucket_region_test(200)
  end

  test "get_storage_region 555" do 
    expected = other_code

    assert expected == get_storage_region :a, Dummy.get_bucket_region_test(555)
  end

  test "get_storage_region error" do 
    expected = "reason"

    assert expected == get_storage_region :a, Dummy.get_bucket_region_test(:error)
  end    

  test "get_storage_class 200" do 
    expected = "Some Class"

    assert expected == get_storage_class :a, Dummy.get_bucket_class_test(200)
  end

  test "get_storage_class 555" do 
    expected = other_code

    assert expected == get_storage_class :a, Dummy.get_bucket_class_test(555)
  end

  test "get_storage_class error" do 
    expected = "reason"

    assert expected == get_storage_class :a, Dummy.get_bucket_class_test(:error)
  end

  test "get_storage_acl 200" do 
    expected = [{"User A", "Type A"}, 
                {"User B", "Type A"}, 
                {"User C", "Type B"}, 
                {"User D", "Type A"}]

    assert expected == get_storage_acl :a, Dummy.get_bucket_acl_test(200)
  end

  test "get_storage_acl 555" do 
    expected = other_code

    assert expected == get_storage_acl :a, Dummy.get_bucket_acl_test(555)
  end

  test "get_storage_acl error" do 
    expected = "reason"

    assert expected == get_storage_acl :a, Dummy.get_bucket_acl_test(:error)
  end

  test "list_classes" do 
    expected = ["STANDARD", "NEARLINE", "DURABLE_REDUCED_AVAILABILITY"]

    assert expected == list_classes
  end

  defp other_code, do: "555: Error message"
  
end
