defmodule Shortener.TCP.ConnectionTest do
  use ExUnit.Case

  @moduletag :capture_log

  doctest Shortener.TCP.Connection

  test "module exists" do
    assert is_list(Shortener.TCP.Connection.module_info())
  end



end
