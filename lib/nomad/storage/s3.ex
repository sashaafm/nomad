defmodule Nomad.Storage.S3 do

  @endpoint "s3.amazonaws.com"

  def list_buckets do 
    HTTPoison.request(
      :get,
      @endpoint,
      "",
      [{"Accept", "application/json"}],
      []
      )
  end
  
end