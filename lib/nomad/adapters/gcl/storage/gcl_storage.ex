if Code.ensure_loaded?(GCloudex) do 

  defmodule Nomad.GCL.Storage do

    @moduledoc"""
    Google Cloud Storage adapter for Nomad. API interaction is done through
    GCloudex.
    """

    defmacro __using__(:gcl) do 
      quote do
        # API functions will be used from this client
        import GCloudex.CloudStorage.Client 
        import Nomad.Utils

        @behaviour NomadStorage

        def list_storages(fun \\ &list_buckets/0) do
          case fun.() do
            {:ok, res} ->
              case res.status_code do
                200 ->
                  res.body
                  |> Friendly.find("name")
                  |> Enum.map(fn bucket -> bucket.text end)
                _   ->
                  res |> show_error_message_and_code
              end
            {:error, reason} ->
              parse_http_error reason
          end
        end

        # def create_storage(bucket, fun \\ &create_bucket/1)  when is_function(fun) do
        #   case fun.(bucket) do
        #     {:ok, res} ->
        #       case res.status_code do
        #         200 -> :ok
        #         _   -> res |> show_error_message_and_code
        #       end
        #     {:error, reason} ->
        #       parse_http_error reason
        #   end
        # end

        # def create_storage(bucket, region, fun \\ &create_bucket/2) when is_binary(region) do
        #   case fun.(bucket, region) do
        #     {:ok, res} ->
        #       case res.status_code do
        #         200 -> :ok
        #         _   -> res |> show_error_message_and_code
        #       end
        #     {:error, reason} ->
        #       parse_http_error reason
        #   end
        # end

        def create_storage(bucket, region, class, fun \\ &create_bucket/3) do
          case fun.(bucket, region, class) do
            {:ok, res} ->
              case res.status_code do
                200 -> :ok
                _   -> res |> show_error_message_and_code
              end
            {:error, reason} ->
              parse_http_error reason
          end
        end

        # def put_item(bucket, filepath, fun \\ &put_object/2) do
        #   case fun.(bucket, filepath) do
        #     {:ok, res} ->
        #       case res.status_code do
        #         200 -> :ok
        #         _   -> res |> show_error_message_and_code
        #       end
        #     {:error, reason} ->
        #       parse_http_error reason
        #   end
        # end

        def put_item(bucket, filepath, storage_path, fun \\ &put_object/3) do
          case fun.(bucket, filepath, storage_path) do
            {:ok, res} ->
              case res.status_code do
                200 -> :ok
                _   -> res |> show_error_message_and_code
              end
            {:error, reason} ->
              parse_http_error reason
          end
        end

        def delete_item(bucket, object, fun \\ &delete_object/2) do
          case fun.(bucket, object) do
            {:ok, res} ->
              case res.status_code do
                204 -> :ok
                _   -> res |> show_error_message_and_code
              end
            {:error, reason} ->
              parse_http_error reason
          end
        end

        def get_item(bucket, object, fun \\ &get_object/2) do
          case fun.(bucket, object) do
            {:ok, res} ->
              case res.status_code do
                200 ->
                  file_content = res.body
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

        def get_item_acl(bucket, object, fun \\ &get_object_acl/2) do
          case fun.(bucket, object) do
            {:ok, res} ->
              case res.status_code do
                200 ->
                  names =
                    res.body
                    |> Friendly.find("entry")
                    |> get_item_acl_names

                  permissions =
                    res.body
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

        def list_items(bucket, fun \\ &list_objects/1) do
          case fun.(bucket) do
            {:ok, res} ->
              case res.status_code do
                200 ->
                  res.body
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

        def delete_storage(bucket, fun \\ &delete_bucket/1) do
          case fun.(bucket) do
            {:ok, res} ->
              case res.status_code do
                204 -> :ok
                _   -> res |> show_error_message_and_code
              end
            {:error, reason} ->
              parse_http_error reason
          end
        end

        def get_storage_region(bucket, fun \\ &get_bucket_region/1) do
          case fun.(bucket) do
            {:ok, res} ->
              case res.status_code do
                200 ->
                  res.body
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

        def get_storage_class(bucket, fun \\ &get_bucket_class/1) do
          case fun.(bucket) do
            {:ok, res} ->
              case res.status_code do
                200 ->
                  res.body
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

        def get_storage_acl(bucket, fun \\ &get_bucket_acl/1) do
          case fun.(bucket) do
            {:ok, res} ->
              case res.status_code do
                200 ->
                  res.body
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