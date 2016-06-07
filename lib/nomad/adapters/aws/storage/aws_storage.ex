if Code.ensure_loaded?(ExAws) do 

  defmodule Nomad.AWS.Storage do
    use ExAws.S3.Client
    import Nomad.Utils

    @moduledoc """
    Amazon Simple Storage Service adapter for Nomad. API interaction is done
    through Ex_AWS.
    """

    defmacro __using__(:aws) do 
      quote do 
        use ExAws.S3.Client
        import Nomad.Utils

        @behaviour NomadStorage

        def config_root do 
          Application.get_all_env(:my_aws_config_root)
        end

        def list_storages(fun \\ &list_buckets/0) do 
          case fun.() do 
            {:ok, res} ->
              case res.status_code do 
                200 ->
                  res.body
                  |> Friendly.find("name")
                  |> Enum.map(fn storage -> storage.text end)
                _   ->
                  get_error_message res
              end
            {:error, reason} ->
              parse_http_error reason
          end
        end

        # def create_storage(name) do 
        #   create_storage name, "us-east-1"
        # end

        # def create_storage(name, region) do 
        #   case put_bucket name, region do 
        #     {:ok, res} ->
        #       case res.status_code do 
        #         200 -> :ok
        #         _   -> get_error_message res
        #       end
        #     {:error, reason} ->
        #       show_message_and_error_code reason
        #   end
        # end

        def create_storage(name, region, class, fun \\ &put_bucket/2) do 
          case fun.(name, region) do 
            {:ok, res} ->
              case res.status_code do 
                200 -> :ok
                _   -> get_error_message res
              end
            {:error, reason} ->
              parse_http_error reason
          end
        end

        # def put_item(bucket, filepath) do
        #   name           = filepath |> String.split("/") |> List.last 
        #   {:ok, content} = File.read filepath

        #   case put_object bucket, name, content do
        #     {:ok, res} ->
        #       case res.status_code do 
        #         200 -> :ok
        #         _   -> get_error_message res
        #       end
        #     {:error, reason} ->
        #       show_message_and_error_code reason
        #   end
        # end
        
        def put_item(bucket, filepath, bucket_path, fun \\ &put_object/3) do
          {:ok, content} = File.read filepath

          case fun.(bucket, bucket_path, content) do
            {:ok, res} ->
              case res.status_code do 
                200 -> :ok
                _   -> get_error_message res
              end
            {:error, reason} ->
              parse_http_error reason
          end
        end

        def list_items(bucket, fun \\ &list_objects/1) do 
          case fun.(bucket) do 
            {:ok, res} ->
              case res.status_code do 
                200 ->
                  res.body
                  |> Friendly.find("key")
                  |> Enum.map(fn object -> object.text end)
                _   -> get_error_message res
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
                _   -> get_error_message res
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
                  {:ok, file} = File.open((object |> String.split("/") |> List.last), [:write])
                  IO.binwrite file, res.body
                  :ok
                _   -> get_error_message res
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
                  res.body
                  |> Friendly.find("accesscontrollist")
                  |> parse_item_acl_entry

                _   -> get_error_message res
              end 
            {:error, reason} ->
              parse_http_error reason
          end
        end

        def delete_storage(bucket, fun \\ &delete_bucket/1) do 
          case fun.(bucket) do 
            {:ok, res} ->
              IO.inspect res
              case res.status_code do 
                204 ->
                  :ok
                _   ->
                  IO.inspect res
                  get_error_message res
              end
            {:error, reason} ->
              parse_http_error reason
          end
        end

        def get_storage_region(bucket, fun \\ &get_bucket_location/1) do 
          case fun.(bucket) do 
            {:ok, res} ->
              case res.status_code do 
                200 ->
                  location = 
                    res.body
                    |> Friendly.find("locationconstraint")
                    |> List.first
                    |> Map.get(:text)

                  exceptional_region location
                _   -> get_error_message res
              end
            {:error, reason} ->
              parse_http_error reason
          end
        end

        defp exceptional_region(location) do 
          if location == "" do 
            "us-east-1"
          else
            location
          end
        end

        def get_storage_class(bucket) do 
          "STANDARD"
        end

        def get_storage_acl(bucket, fun \\ &get_bucket_acl/1) do 
          case fun.(bucket) do 
            {:ok, res} ->
              case res.status_code do
                200 ->
                  res.body
                  |> Friendly.find("accesscontrollist")
                  |> map_storage_acl_entries
                  |> List.flatten

                _   -> get_error_message res
              end
            {:error, reason} -> 
              parse_http_error reason
          end
        end

        @spec list_classes() :: list(binary)
        def list_classes do 
          ["STANDARD"]
        end

        defp map_storage_acl_entries(aclist) do 
          aclist
          |> Enum.map(fn entry -> parse_storage_acl_entry entry end)
        end

        defp parse_storage_acl_entry(entry) do 
          entry 
          |> Map.get(:elements) 
          |> Enum.map(fn entry -> 
                       {(entry 
                        |> Map.get(:elements) 
                        |> List.first 
                        |> Map.get(:elements) 
                        |> List.last 
                        |> Map.get(:text)), 
                        entry 
                        |> Map.get(:elements) 
                        |> List.last 
                        |> Map.get(:text)} 
                      end)    
        end
        
        defp parse_item_acl_entry(enum) do 
          enum
          |> Enum.map(fn entry -> 
              {entry 
               |> Map.get(:elements)
               |> List.first
               |> Map.get(:elements)
               |> List.first
               |> Map.get(:elements)
               |> List.last
               |> Map.get(:text),
               entry
               |> Map.get(:elements)
               |> List.last
               |> Map.get(:elements)
               |> List.last
               |> Map.get(:text)}
            end)
        end
      end
    end
  end
end
