if Code.ensure_loaded?(GCloudex) do 

  defmodule Nomad.GCL.Storage do

    @moduledoc"""
    Google Cloud Storage adapter for Nomad. API interaction is done through
    GCloudex.
    """

    defmacro __using__(:gcl) do 
      quote do
        alias GCloudex.CloudStorage.Client, as: GCSClient
        import Nomad.Utils

        @behaviour NomadStorage
        
        @endpoint "storage.googleapis.com"

        @doc"""
        List all available storages to the Google Cloud account.
        """
        @spec list_storages() :: [binary] | binary
        def list_storages do
          case GCSClient.list_buckets do
            {:ok, res} ->
              case res.status_code do
                200 ->
                  res
                  |> Map.get(:body)
                  |> Friendly.find("name")
                  |> Enum.map(fn bucket -> bucket.text end)
                _   ->
                  res |> show_error_message_and_code
              end
            {:error, reason} ->
              parse_http_error reason
          end
        end

        @doc"""
        Creates a new Google Cloud Storage bucket with the name 'bucket' in the
        default region and with the default class.
        """
        @spec create_storage(binary) :: :ok | binary
        def create_storage(bucket) do
          case GCSClient.create_bucket bucket do
            {:ok, res} ->
              case res.status_code do
                200 -> :ok
                _   -> res |> show_error_message_and_code
              end
            {:error, reason} ->
              parse_http_error reason
          end
        end

        @doc"""
        Creates a new Google Cloud Storage bucket with the name 'bucket' in the
        specified 'region' and with the default class.
        """
        @spec create_storage(binary, binary) :: :ok | binary
        def create_storage(bucket, region) do
          case GCSClient.create_bucket bucket, region do
            {:ok, res} ->
              case res.status_code do
                200 -> :ok
                _   -> res |> show_error_message_and_code
              end
            {:error, reason} ->
              parse_http_error reason
          end

        end

        @doc"""
        Creates a new Google Cloud Storage bucket with the name 'bucket' in the
        specified 'region' and with the specified 'class'.
        """
        @spec create_storage(binary, binary, binary) :: :ok | binary
        def create_storage(bucket, region, class) do
          case GCSClient.create_bucket bucket, region, class do
            {:ok, res} ->
              case res.status_code do
                200 -> :ok
                _   -> res |> show_error_message_and_code
              end
            {:error, reason} ->
              parse_http_error reason
          end
        end

        @doc"""
        Uploads the file in the given 'filepath' to the specified 'bucket'.
        """
        @spec put_item(binary, binary) :: :ok | binary
        def put_item(bucket, filepath) do
          case GCSClient.put_object bucket, filepath do
            {:ok, res} ->
              case res.status_code do
                200 -> :ok
                _   -> res |> show_error_message_and_code
              end
            {:error, reason} ->
              parse_http_error reason
          end
        end

        @doc"""
        Uploads the file in the given 'filepath' to the specified 'bucket' and store
        it in the specified 'storage_path'. The necessaries directories in
        'storage_path' will be created if they do not exist.
        """
        @spec put_item(binary, binary) :: :ok | binary
        def put_item(bucket, filepath, storage_path) do
          case GCSClient.put_object bucket, filepath, storage_path do
            {:ok, res} ->
              case res.status_code do
                200 -> :ok
                _   -> res |> show_error_message_and_code
              end
            {:error, reason} ->
              parse_http_error reason
          end
        end

        @doc"""
        Deletes the specified 'object' from the given 'bucket'.
        """
        @spec delete_item(binary, binary) :: :ok | binary
        def delete_item(bucket, object) do
          case GCSClient.delete_object bucket, object do
            {:ok, res} ->
              case res.status_code do
                204 -> :ok
                _   -> res |> show_error_message_and_code
              end
            {:error, reason} ->
              parse_http_error reason
          end
        end

        @doc"""
        Downloads the specified 'object' from the given 'bucket' if it exists. The
        file will be written into the current working directory.
        """
        @spec get_item(binary, binary) :: :ok | binary
        def get_item(bucket, object) do
          case GCSClient.get_object bucket, object do
            {:ok, res} ->
              case res.status_code do
                200 ->
                  file_content = Map.get res, :body
                  {:ok, file}  = File.open object, [:write]
                  IO.binwrite file, file_content
                  :ok
                _   ->
                  res |> show_error_message_and_code
              end

            {:error, reason} ->
              parse_http_error reason
          end
        end

        @doc"""
        Lists the given 'object' ACL from the specified 'bucket'.
        """
        @spec get_item_acl(binary, binary) :: [{binary, binary}] | binary
        def get_item_acl(bucket, object) do
          case GCSClient.get_object_acl bucket, object do
            {:ok, res} ->
              case res.status_code do
                200 ->
                  names =
                    res
                    |> Map.get(:body)
                    |> Friendly.find("entry")
                    |> get_item_acl_names

                  permissions =
                    res
                    |> Map.get(:body)
                    |> Friendly.find("entry")
                    |> get_item_acl_permissions

                  {names, permissions}
                  |> Tuple.to_list
                  |> List.zip
                _   ->
                  res |> show_error_message_and_code
              end

            {:error, reason} ->
              parse_http_error reason
          end
        end

        defp get_item_acl_names(enum) do
          enum
          |> Enum.map(fn entry ->
                      entry.elements
                      |> Enum.map(fn element ->
                                     element.elements
                                     |> List.last
                                  end)
                     end)
          |> Enum.map(fn a ->
                         a
                         |> List.first
                         |> Map.get(:text)
                      end)
        end

        defp get_item_acl_permissions(enum) do
          enum
          |> Enum.map(fn entry ->
                         entry.elements
                         |> List.last
                         |> Map.get(:text)
                      end)
        end

        @doc"""
        Lists the items from the specified 'bucket'.
        """
        @spec list_items(binary) :: [binary] | binary
        def list_items(bucket) do
          case GCSClient.list_objects bucket do
            {:ok, res} ->
              case res.status_code do
                200 ->
                  objects = res
                            |> Map.get(:body)
                            |> Friendly.find("key")
                            |> Enum.map(fn object -> object.texts end)
                            |> List.flatten
                _   ->
                  res |> show_error_message_and_code
              end
            {:error, reason} ->
              parse_http_error reason
          end
        end

        @doc"""
        Deletes the specified 'bucket' if it is empty.
        """
        @spec delete_storage(binary) :: :ok | binary
        def delete_storage(bucket) do
          case GCSClient.delete_bucket bucket do
            {:ok, res} ->
              case res.status_code do
                204 -> :ok
                _   -> res |> show_error_message_and_code
              end
            {:error, reason} ->
              parse_http_error reason
          end
        end

        @doc"""
        Lists the specified 'bucket' region.
        """
        @spec get_storage_region(binary) :: binary
        def get_storage_region(bucket) do
          case GCSClient.get_bucket_region bucket do
            {:ok, res} ->
              case res.status_code do
                200 ->
                  res
                  |> Map.get(:body)
                  |> Friendly.find("locationconstraint")
                  |> List.first
                  |> Map.get(:texts)
                  |> List.first

                _   ->
                  res |> show_error_message_and_code
              end
            {:error, reason} ->
              parse_http_error reason
          end
        end

        @doc"""
        Lists the specified 'bucket' class.
        """
        @spec get_storage_class(binary) :: binary
        def get_storage_class(bucket) do
          case GCSClient.get_bucket_class bucket do
            {:ok, res} ->
              case res.status_code do
                200 ->
                  res
                  |> Map.get(:body)
                  |> Friendly.find("storageclass")
                  |> List.first
                  |> Map.get(:texts)
                  |> List.first
                _   ->
                  res |> show_error_message_and_code
              end
            {:error, reason} ->
              parse_http_error reason
          end
        end

        @doc"""
        Lists the specified 'bucket' ACL.
        """
        @spec get_storage_acl(binary) :: [{binary, binary}] | binary
        def get_storage_acl(bucket) do
          case GCSClient.get_bucket_acl bucket do
            {:ok, res} ->
              case res.status_code do
                200 ->
                  res
                  |> Map.get(:body)
                  |> Friendly.find("entry")
                  |> parse_acl_entry
                _   ->
                  res |> show_error_message_and_code
              end
            {:error, reason} ->
              parse_http_error reason
          end
        end

        defp parse_acl_entry(enum) do
          enum
          |> Enum.map(fn entry ->
                          {entry.elements
                           |> List.first
                           |> Map.get(:elements)
                           |> List.last
                           |> Map.get(:text),
                           entry.elements
                           |> List.last
                           |> Map.get(:text)}
                      end)
        end

        @doc """
        Lists all the available classes for Cloud Storage buckets.
        """
        @spec list_classes :: [binary]
        def list_classes do
          ["STANDARD", "NEARLINE", "DURABLE_REDUCED_AVAILABILITY"]
        end
      end
    end
  end
end