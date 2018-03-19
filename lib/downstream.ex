defmodule Downstream do
  @moduledoc """
  `Downstream` is an Elixir client for streaming downloads via GET or POST requests,
  by relying on `HTTPoison`.

  `Downstream` is simple to use, just pass it a URL and an IO device:
  """

  alias Downstream.Download

  @request_timeout 60_000

  @spec get(binary, IO.device(), [{binary, binary}]) :: {atom, binary}
  @doc ~S"""
  Downloads from a given URL with a GET request.

  Returns `{:ok, io_device}` if the download is successful, and `{:error, reason}`
  otherwise.
  """
  def get(url, io_device, headers \\ []) do
    download_task = Task.async(Download, :stream, [io_device])

    HTTPoison.get!(url, headers, stream_to: download_task.pid)

    Task.await(download_task, @request_timeout)
  end

  @doc ~S"""
  Downloads from the given URL with a GET request, raising an exception in the case of failure.

  If the request succeeds, the IO device is returned.
  """
  @spec get!(binary, IO.device(), [{binary, binary}]) :: binary
  def get!(url, io_device, headers \\ []) do
    case get(url, io_device, headers) do
      {:error, error} -> raise to_string(error)
      {:ok, io_device} -> io_device
    end
  end

  @spec post(binary, IO.device(), binary | {atom, any}, [{binary, binary}]) :: {atom, binary}
  @doc ~S"""
  Downloads from a given URL with a POST request.

  Returns `{:ok, io_device}` if the download is successful, and `{:error, reason}`
  otherwise.
  """
  def post(url, io_device, body \\ "", headers \\ []) do
    download_task = Task.async(Download, :stream, [io_device])

    HTTPoison.post!(url, body, headers, stream_to: download_task.pid)

    Task.await(download_task, @request_timeout)
  end

  @spec post!(binary, IO.device(), binary | {atom, any}, [{binary, binary}]) :: binary
  @doc ~S"""
  Downloads from the given URL with a POST request, raising an exception in the case of failure.

  If the request succeeds, the IO device is returned.
  """
  def post!(url, io_device, body \\ "", headers \\ []) do
    case post(url, io_device, body, headers) do
      {:error, error} -> raise to_string(error)
      {:ok, io_device} -> io_device
    end
  end
end
