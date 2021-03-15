defmodule Management.Behaviours.FileStorage do
  @moduledoc """
  Defines the interface for uploading a file from to a cloud storage and getting the
  files from the cloud storage
  """
  @typep reason :: binary()
  @typep path :: binary()

  @callback upload() :: {:ok, path} | {:error, reason()}

  @callback download(path()) :: {:ok, bitstring()} | {:error, reason()}
end
