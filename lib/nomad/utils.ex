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

  def show_message_and_error_code({:http_error, code, body}) do 
    msg = body |> Friendly.find("message") |> List.last |> Map.get(:text)
    
    Integer.to_string(code) <> ": " <> msg
  end

  def get_error_message(res) do 
    msg  = res.body |> Friendly.find("message") |> List.last |> Map.get(:text)
    code = res.status_code |> Integer.to_string

    code <> ": " <> msg
  end    

  def show_error_message_and_code(res) do
    msg  = res.body |> Friendly.find("message") |> List.last |> Map.get(:text)
    code = res.status_code |> Integer.to_string

    code <> ": " <> msg
  end

  def show_error_message_and_code(res, :json) do
    msg  = res.body |> Poison.decode! |> Map.get("error") |> Map.get("message")
    code = res.body |> Poison.decode! |> Map.get("error") |> Map.get("code") |> Integer.to_string

    code <> ": " <> msg
  end  

  def parse_http_error(%HTTPoison.Error{id: _id, reason: reason}) do
    reason |> Atom.to_string
  end
  def parse_http_error({:http_error, code, body}) do
    c = Integer.to_string(code)
    m = body |> Friendly.find("message") |> List.first |> Map.get(:text)
    "#{c}: #{m}"
  end
end
