defmodule Dummy.Test.AWSStorageClient do
  use Nomad.AWS.Storage, :aws

  def list_buckets_test(state) do 
    fn ->
      case state do 
        200    -> {:ok, %{status_code: 200, body: "<Name>ABC</Name><Name>DEF</Name>"}}
        555    -> code_555
        :error -> http_error
        :empty -> {:ok, %{status_code: 200, body: ""}}
      end
    end
  end

  def create_bucket_test(state) do 
    fn (_name, _region, _class) ->
      case state do 
        200    -> {:ok, %{status_code: 200}}
        555    -> code_555
        :error -> http_error
      end
    end
  end

  def put_object_test(state) do 
    fn (_bucket, _bucket_path, _content) ->
      case state do 
        200    -> {:ok, %{status_code: 200}}
        555    -> code_555
        :error -> http_error
      end
    end
  end

  def list_objects_test(state) do 
    fn (_bucket) ->
      case state do 
        200    -> {:ok, %{status_code: 200, body: "<Key>ABC</Key><Key>DEF</Key>"}}
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
        200    -> {:ok, %{status_code: 200, body: "ABC"}}
        555    -> code_555
        :error -> http_error
      end
    end
  end

  def get_object_acl_test(state) do 
    fn (_bucket, _object) ->
      case state do 
        200    -> {:ok, %{status_code: 200, body: acl_body}}
        555    -> code_555
        :error -> http_error
      end
    end
  end

  def delete_bucket_test(state) do 
    fn (_bucket) ->
      case state do 
        204    -> {:ok, %{status_code: 204, body: ""}}
        555    -> code_555
        :error -> http_error
      end
    end
  end

  def get_bucket_region_test(state) do 
    fn (_bucket) ->
      case state do 
        200    -> {:ok, %{status_code: 200, body: "<LocationConstraint>Region</LocationConstraint"}}
        555    -> code_555
        :error -> http_error
      end
    end
  end

  def get_bucket_acl_test(state) do 
    fn (_bucket) ->
      case state do 
        200    -> {:ok, %{status_code: 200, body: acl_body}}
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
    <?xml version=\"1.0\" encoding=\"UTF-8\"?>
      <AccessControlPolicy xmlns=\"http://s3.amazonaws.com/doc/2006-03-01/\">
        <Owner>
          <ID>7afc2277478eae15646381519160785b68abe1434968f7d9f7b38b590c08560a</ID>
          <DisplayName>sashaafm</DisplayName>
        </Owner>
        <AccessControlList>
          <Grant>
            <Grantee xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:type=\"CanonicalUser\">
              <ID>7afc2277478eae15646381519160785b68abe1434968f7d9f7b38b590c08560a</ID>
              <DisplayName>sashaafm</DisplayName>
            </Grantee>
            <Permission>FULL_CONTROL</Permission>
          </Grant>
        </AccessControlList>
      </AccessControlPolicy>
    """
  end
end

defmodule AwsStorageTest do
  use ExUnit.Case
  use Nomad.AWS.Storage, :aws
  alias Dummy.Test.AWSStorageClient, as: Dummy

  test "list_storages 200" do 
    expected = ["ABC", "DEF"]

    assert expected == list_storages Dummy.list_buckets_test 200
  end

  test "list_storages 555" do 
    expected = other_code

    assert expected == list_storages Dummy.list_buckets_test 555
  end

  test "list_storages error" do
    expected = "reason"

    assert expected == list_storages Dummy.list_buckets_test :error
  end

  test "list_storages empty" do 
    expected = []

    assert expected == list_storages Dummy.list_buckets_test :empty
  end

  test "create_storage 200" do 
    expected = :ok

    assert expected == create_storage :a, :b, :c, Dummy.create_bucket_test 200
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

    assert expected == put_item :a, "mix.lock", :c, Dummy.put_object_test 200
  end

  test "put_item 555" do 
    expected = other_code

    assert expected == put_item :a, "mix.lock", :c, Dummy.put_object_test 555
  end

  test "put_item error" do 
    expected = "reason"

    assert expected == put_item :a, "mix.lock", :c, Dummy.put_object_test :error
  end

  test "list_items 200" do 
    expected = ["ABC", "DEF"]

    assert expected == list_items :a, Dummy.list_objects_test 200
  end

  test "list_items 555" do 
    expected = other_code

    assert expected == list_items :a, Dummy.list_objects_test 555
  end  

  test "list_items error" do 
    expected = "reason"

    assert expected == list_items :a, Dummy.list_objects_test :error
  end  

  test "delete_item 204" do 
    expected = :ok

    assert expected == delete_item :a, :b, Dummy.delete_object_test 204
  end

  test "delete_item 555" do 
    expected = other_code

    assert expected == delete_item :a, :b, Dummy.delete_object_test 555
  end

  test "delete_item error" do 
    expected = "reason"

    assert expected == delete_item :a, :b, Dummy.delete_object_test :error
  end    

  test "get_item 200" do 
    expected = :ok

    assert expected == get_item :a, "file", Dummy.get_object_test 200

    :ok = File.rm! "file"
  end

  test "get_item 555" do 
    expected = other_code

    assert expected == get_item :a, "file", Dummy.get_object_test 555
  end

  test "get_item error" do 
    expected = "reason"

    assert expected == get_item :a, "file", Dummy.get_object_test :error
  end

  test "get_item_acl 200" do 
    expected = [{"sashaafm", "FULL_CONTROL"}]

    assert expected == get_item_acl :a, :b, Dummy.get_object_acl_test 200
  end

  test "get_item_acl 555" do
    expected = other_code

    assert expected == get_item_acl :a, :b, Dummy.get_object_acl_test 555
  end

  test "get_item error" do 
    expected = "reason"

    assert expected == get_item_acl :a, :b, Dummy.get_object_acl_test :error
  end

  test "delete_storage 204" do 
    expected = :ok

    assert expected == delete_storage :a, Dummy.delete_bucket_test 204
  end

  test "delete_storage 555" do 
    expected = other_code

    assert expected == delete_storage :a, Dummy.delete_bucket_test 555
  end

  test "delete_storage error" do 
    expected = "reason"

    assert expected == delete_storage :a, Dummy.delete_bucket_test :error
  end

  test "get_storage_region 200" do 
    expected = "Region"

    assert expected == get_storage_region :a, Dummy.get_bucket_region_test 200
  end

  test "get_storage_region 555" do 
    expected = other_code

    assert expected == get_storage_region :a, Dummy.get_bucket_region_test 555
  end

  test "get_storage_region error" do 
    expected = "reason"

    assert expected == get_storage_region :a, Dummy.get_bucket_region_test :error
  end

  test "get_storage_class" do 

    assert "STANDARD" == get_storage_class :a
  end

  test "get_bucket_acl 200" do
    expected = [{"sashaafm", "FULL_CONTROL"}]

    assert expected == get_storage_acl :a, Dummy.get_bucket_acl_test 200
  end

  test "get_bucket_acl 555" do 
    expected = other_code

    assert expected == get_storage_acl :a, Dummy.get_bucket_acl_test 555
  end

  test "get_bucket_acl error" do 
    expected = "reason"

    assert expected == get_storage_acl :a, Dummy.get_bucket_acl_test :error
  end

  defp other_code, do: "555: Error message"  
end