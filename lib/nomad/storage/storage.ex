defmodule Nomad.Storage do

  #@provider Application.get_env(:nomad, :provider)

  def insert(item) when @provider == :aws do 
    # aws.insert item
  end

  def insert(item) when @provider == :gcl do 
    # gcs.insert item
  end
  
end