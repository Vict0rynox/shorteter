defmodule Shortener.TCP.Handler do
  @moduledoc false

  defp error(worker) do
    """
      An error occurred handling the command.
      Plesae check you syntax.

    """ <> process(worker, "/help")
  end

  def process(_worker, "/help") do
    """
      Available commands:
        * /help - display this message
        * /shorten [alias] [url] - shorten a url
        * /url [alias] - get a url by the alisa
    """
  end

  def process(worker, "/shorten " <> input) do
    case String.split(input, " ") do
      [short, url] ->
        case Shortener.Worker.shorten(worker, short, url) do
          :ok -> "URL shortened!"
          {:error, :dupalias} -> "This alias is already being used by a different url."
        end
      _ -> error(worker)
    end
  end

  def process(worker, "/url " <> short) do
    case Shortener.Worker.url(worker, short) do
      {:ok, url} -> url
      _ -> "URL does not exits."
    end
  end

  def process(worker, _), do: error(worker)

end
