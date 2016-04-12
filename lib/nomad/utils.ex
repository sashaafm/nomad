defmodule Nomad.Utils do
  alias HTTPoison, as: HTTP

  @moduledoc """
  Offers auxiliary functions for Nomad workflows.
  """

  @doc """
  Returns the current machine's public IP address. An HTTP call is made to the
  ipecho.net service and the reply is parsed. If this service goes down in the
  future another one will have to take it's place.
  """
  @spec find_public_ip_address() :: binary
  def find_public_ip_address do
    {:ok, res} = HTTP.request(:get, "http://ipecho.net/plain", "", [], [])
    res.body
  end
end