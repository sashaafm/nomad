defmodule Nomad.CloudSetupScript do
  @behaviour Script
  
  @moduledoc """
  
  """

  ### THIS FILE SHOULD BE WRITTEN TO TEMP????
  def build_script do
    {:ok, script} = File.open "cloud_setup.sh", [:write]

    :ok = IO.binwrite script, bs
    File.close script
  end

  defp bs do
    """
    #!/bin/bash

    sudo apt-get install -y build-essential
    wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && sudo dpkg -i erlang-solutions_1.0_all.deb
    sudo apt-get update
    sudo apt-get install -y erlang-asn1 erlang-base erlang-crypto erlang-inets erlang-mnesia
    sudo apt-get install -y erlang-public-key erlang-runtime-tools erlang-solutions erlang-ssl 
    sudo apt-get install -y erlang-dev erlang-base-hipe erlang-eunit erlang-syntax-tools
    sudo apt-get install -y elixir
    sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password'
    sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password'
    sudo apt-get -y install mysql-server
    """
  end

  def delete_script do
    File.rm "cloud_setup.sh"
  end
  
end