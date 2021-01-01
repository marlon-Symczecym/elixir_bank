defmodule User do
  defstruct name: nil, email: nil, cpf: nil

  def new(name, email, cpf), do: %__MODULE__{name: name, email: email, cpf: cpf}
end
