defmodule ShortenerWorkerTest do
  use ExUnit.Case

  @moduletag :capture_log

  doctest Shortener.Worker

  test "module exists" do
    assert is_list(Shortener.Worker.module_info())
  end

  setup do
    table = :ets.new(:urls, [:set, :public])
    {:ok, worker1} = Shortener.Worker.start_link(table)
    {:ok, worker2} = Shortener.Worker.start_link(table)
    {:ok, table: table, w1: worker1, w2: worker2}
  end

  test "reading a shortened url from any worker", state do
    %{table: table, w1: worker1, w2: worker2} = state

    :ets.insert(table, {"gl", "http://google.com"})

    assert {:ok, "http://google.com"} == Shortener.Worker.url(worker1, "gl")
    assert {:ok, "http://google.com"} == Shortener.Worker.url(worker2, "gl")
  end

  test "shortening url from worker", state do
    %{table: table, w1: worker1, w2: worker2} = state

    assert :ok == Shortener.Worker.shorten(worker1, "gl", "http://google.com")
    assert [{"gl", "http://google.com"}] == :ets.lookup(table, "gl")

    assert :ok == Shortener.Worker.shorten(worker2, "glua", "http://google.com.ua")
    assert [{"glua", "http://google.com.ua"}] == :ets.lookup(table, "glua")
  end


  test "shortening existing url from any worker", state do
    %{table: table, w1: worker1, w2: worker2} = state

    :ets.insert(table, {"gl", "http://google.com"})

    assert {:ok, "http://google.com"} == Shortener.Worker.url(worker1, "gl")
    assert {:ok, "http://google.com"} == Shortener.Worker.url(worker1, "gl")


    assert {:error, :dupalias} == Shortener.Worker.shorten(worker1, "gl", "http://google.com")
    assert {:error, :dupalias} == Shortener.Worker.shorten(worker2, "gl", "http://google.com")
  end


  test "shortening url from one worker and find from second", state do
    %{w1: worker1, w2: worker2} = state

    assert :ok == Shortener.Worker.shorten(worker1, "gl", "http://google.com")
    assert {:ok, "http://google.com"} == Shortener.Worker.url(worker2, "gl")
    assert {:ok, "http://google.com"} == Shortener.Worker.url(worker1, "gl")

    assert :ok == Shortener.Worker.shorten(worker2, "glua", "http://google.com.ua")
    assert {:ok, "http://google.com.ua"} == Shortener.Worker.url(worker2, "glua")
    assert {:ok, "http://google.com.ua"} == Shortener.Worker.url(worker1, "glua")
  end


end
