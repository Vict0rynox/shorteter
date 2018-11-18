defmodule Shortener.Worker do
  use GenServer

  # Client API

  def start_link(table, opts \\ []) do
    GenServer.start_link(__MODULE__, table, opts)
  end

  def url(pid, short) do
    GenServer.call(pid, {:url, short})
  end

  def shorten(pid, short, url) do
    GenServer.call(pid, {:shorten, short, url})
  end

  # Callback
  def init(table) do
    {:ok, table}
  end

  def handle_call({:shorten, short, url}, _from, table) do
    if :ets.insert_new(table, {short, url}),
       do: {:reply, :ok, table},
       else: {:reply, {:error, :dupalias}, table}
  end

  def handle_call({:url, short}, _from, table) do
    case :ets.lookup(table, short) do
      [{_, url}] -> {:reply, {:ok, url}, table}
      _ -> {:reply, :error, table}
    end
  end


end
