defmodule Shortener.TCP.HandlerTest do
  use ExUnit.Case

  @moduletag :capture_log

  alias Shortener.TCP.{Handler}
  doctest Shortener.TCP.Handler

  test "module exists" do
    assert is_list(Shortener.TCP.Handler.module_info())
  end

  setup do
    table = :ets.new(:urls, [:set, :public])
    {:ok, worker} = Shortener.Worker.start_link(table)
    {:ok, table: table, w: worker}
  end

  test "command /help test", state do
    %{w: worker} = state
    help = """
      Available commands:
        * /help - display this message
        * /shorten [alias] [url] - shorten a url
        * /url [alias] - get a url by the alisa
    """
    assert help == Handler.process(worker, "/help")
  end

  test "command /shorten test", state do
    %{table: table, w: worker} = state
    assert "URL shortened!" == Handler.process(worker, "/shorten gl http://google.com")
    assert [{"gl", "http://google.com"}] == :ets.lookup(table, "gl")
  end

  test "command /url test", state do
    %{table: table, w: worker} = state
    :ets.insert_new(table, {"gl", "http://google.com"})
    assert "http://google.com" == Handler.process(worker, "/url gl")
  end

end
