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

        def list_storages do 
          case list_buckets do 
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
              show_message_and_error_code reason
          end
        end

        def create_storage(name) do 
          create_storage name, "us-east-1"
        end

        def create_storage(name, region) do 
          case put_bucket name, region do 
            {:ok, res} ->
              case res.status_code do 
                200 -> :ok
                _   -> get_error_message res
              end
            {:error, reason} ->
              show_message_and_error_code reason
          end
        end

        def create_storage(name, region, _class) do 
          create_storage name, region
        end

        def put_item(bucket, filepath) do
          name           = filepath |> String.split("/") |> List.last 
          {:ok, content} = File.read filepath

          case put_object bucket, name, content do
            {:ok, res} ->
              case res.status_code do 
                200 -> :ok
                _   -> get_error_message res
              end
            {:error, reason} ->
              show_message_and_error_code reason
          end
        end
        
        def put_item(bucket, filepath, bucket_path) do
          {:ok, content} = File.read filepath

          case put_object bucket, bucket_path, content do
            {:ok, res} ->
              case res.status_code do 
                200 -> :ok
                _   -> get_error_message res
              end
            {:error, reason} ->
              show_message_and_error_code reason
          end
        end

        def list_items(bucket) do 
          case list_objects bucket do 
            {:ok, res} ->
              case res.status_code do 
                200 ->
                  res.body
                  |> Friendly.find("key")
                  |> Enum.map(fn object -> object.text end)
                _   -> get_error_message res
              end
            {:error, reason} ->
              show_message_and_error_code reason
          end
        end

        def delete_item(bucket, object) do 
          case delete_object bucket, object do 
            {:ok, res} ->
              case res.status_code do 
                204 -> :ok
                _   -> get_error_message res
              end        
            {:error, reason} ->
              show_message_and_error_code reason
          end
        end

        def get_item(bucket, object) do 
          case get_object(bucket, object) do 
            {:ok, res} ->
              case res.status_code do 
                200 ->
                  {:ok, file} = File.open((object |> String.split("/") |> List.last), [:write])
                  IO.binwrite file, res.body
                  :ok
                _   -> get_error_message res
              end
            {:error, reason} ->
              show_message_and_error_code reason
          end
        end

        def get_item_acl(bucket, object) do 
          case get_object_acl(bucket, object) do 
            {:ok, res} ->
              case res.status_code do
                200 ->
                  res.body
                  |> Friendly.find("accesscontrollist")
                  |> parse_item_acl_entry

                _   -> get_error_message res
              end 
            {:error, reason} ->
              show_message_and_error_code reason
          end
        end

        def delete_storage(bucket) do 
          case delete_bucket bucket do 
            {:ok, res} ->
              case res.status_code do 
                204 ->
                  :ok
                _   -> get_error_message res
              end
            {:error, reason} ->
              show_message_and_error_code reason
          end
        end

        # NOT WORKING CORRECTLY
        def get_storage_region(bucket) do 
          case get_bucket_location bucket do 
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
              show_message_and_error_code reason
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

        def get_storage_acl(bucket) do 
          case get_bucket_acl bucket do 
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
              show_message_and_error_code reason
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