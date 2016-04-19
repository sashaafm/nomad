defmodule Nomad.RemoteSetupScript do
  @behaviour Script
  
  @moduledoc """
  Builds and deletes the script for the setup of the remote host.
  """

  @doc """
  Builds the script for the setup of the remote host.
  The script installs all the necessary packages for Elixir/Phoenix and MySQL.
  """
  def build_script do
    {:ok, script} = File.open "remote_setup.sh", [:write]

    :ok = IO.binwrite script, bs
    File.close script
  end

  ### JUST FOR MYSQL FOR NOW ####
  ### NEEDS TO RECEIVE THE MYSQL PASSWORD ###
  defp bs do
    """
    #!/bin/bash

    export DEBIAN_FRONTEND=noninteractive

    sudo apt-get install -y build-essential
    wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && sudo dpkg -i erlang-solutions_1.0_all.deb
    sudo apt-get update
    sudo apt-get install -y erlang-asn1 erlang-base erlang-crypto erlang-inets erlang-mnesia
    sudo apt-get install -y erlang-public-key erlang-runtime-tools erlang-solutions erlang-ssl 
    sudo apt-get install -y erlang-dev erlang-base-hipe erlang-eunit erlang-syntax-tools
    sudo apt-get install -y elixir
    echo mysql-server mysql-server/root_password password root | sudo debconf-set-selections
    echo mysql-server mysql-server/root_password_again password root | sudo debconf-set-selections
    sudo -E apt-get -q -y install mysql-server
    sudo apt-get -y install nginx
    """
  end

  @doc """
  Deletes the remote setup script from the local directory.
  """
  def delete_script do
    File.rm "remote_setup.sh"
  end
  
end