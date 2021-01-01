defmodule BankHelpers do
  def write(binary, file) do
    file
    |> File.write(binary)
  end

  def read(file) do
    {:ok, list} = file |> File.read()

    list
    |> :erlang.binary_to_term()
  end
end
