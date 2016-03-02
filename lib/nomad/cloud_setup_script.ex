defmodule Nomad.CloudSetupScript do
  @behaviour Script
  
  @moduledoc """
  Builds and deletes the script for the setup of the cloud host.
  """

  @doc """
  Builds the script for the setup of the cloud host.
  The script installs all the necessary packages for Elixir/Phoenix and MySQL.
  """
  def build_script do
    {:ok, script} = File.open "cloud_setup.sh", [:write]

    :ok = IO.binwrite script, bs
    File.close script
  end

  ### SÓ ESTÁ PARA MYSQL ####
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

  @doc """
  Deletes the cloud setup script from the local directory.
  """
  def delete_script do
    File.rm "cloud_setup.sh"
  end
  
end