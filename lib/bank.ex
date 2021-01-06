defmodule Bank do
  @account_path "files"
  @register_file %{
    :accounts => "#{@account_path}/account.txt",
    :transation => "#{@account_path}/transations.txt"
  }

  def start do
    File.mkdir(@account_path)
    File.write(@register_file[:accounts], :erlang.term_to_binary([]))
    File.write(@register_file[:transation], :erlang.term_to_binary([]))
  end

  def register(name, email, cpf) do
    cond do
      File.exists?(@register_file[:accounts]) == true ->
        User.new(name, email, cpf)
        |> Accounts.register()

      File.exists?(@register_file[:accounts]) == false ->
        start()

        User.new(name, email, cpf)
        |> Accounts.register()
    end
  end

  def search_accounts(), do: BankHelpers.read(@register_file[:accounts])
  def search_transations(), do: BankHelpers.read(@register_file[:transation])

  def transfer(from_cpf, to_cpf, value), do: Accounts.transfer(from_cpf, to_cpf, value)

  def callin(account_cpf, value), do: Accounts.callin(account_cpf, value)
end
