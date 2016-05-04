defmodule GclStorageText do
  use ExUnit.Case
  alias Nomad.Storage, as: API

  test "list storages empty" do 
    assert [] == API.list_storages
  end
  
end