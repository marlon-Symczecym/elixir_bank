defmodule Accounts do
  defstruct user: User, balance: 1000

  @account_path "files"
  @register_file %{
    :accounts => "#{@account_path}/account.txt"
  }

  def register(user) do
    case search_account(user.cpf) do
      nil ->
        (BankHelpers.read(@register_file[:accounts]) ++
           [%__MODULE__{user: user}])
        |> :erlang.term_to_binary()
        |> BankHelpers.write(@register_file[:accounts])

      _ ->
        {:error, "Usuario com cpf: #{user.cpf} ja tem conta cadastrada"}
    end
  end

  def search_account(user_cpf) do
    BankHelpers.read(@register_file[:accounts])
    |> Enum.find(&(&1.user.cpf == user_cpf))
  end

  def transfer(from_cpf, to_cpf, value) do
    from = from_cpf |> search_account()
    to = to_cpf |> search_account()

    cond do
      from.balance |> validate_balance(value) ->
        {:error, "Saldo insuficiente"}

      true ->
        account = [from, to] |> delete_accounts()

        from = %__MODULE__{from | balance: from.balance - value}
        to = %__MODULE__{to | balance: to.balance + value}

        Transations.register(
          :transference,
          from.user.cpf,
          value,
          DateTime.utc_now(),
          to.user.cpf
        )

        (account ++ [from, to])
        |> :erlang.term_to_binary()
        |> BankHelpers.write(@register_file[:accounts])

        {:ok, "#{from.user.name} transferiu R$ #{value} reais para #{to.user.name}"}
    end
  end

  defp delete_accounts(accounts) do
    accounts
    |> Enum.reduce(BankHelpers.read(@register_file[:accounts]), fn e, acc ->
      List.delete(acc, e)
    end)
  end

  def callin(account_cpf, value) do
    account_from = account_cpf |> search_account()

    cond do
      account_from.balance |> validate_balance(value) ->
        {:error, "Saldo insuficiente"}

      true ->
        accounts = [account_from] |> delete_accounts()

        new_account = %__MODULE__{account_from | balance: account_from.balance - value}

        (accounts ++ [new_account])
        |> :erlang.term_to_binary()
        |> BankHelpers.write(@register_file[:accounts])

        {:ok, new_account.user.name, "Mensagem de email encaminhada"}
    end
  end

  defp validate_balance(balance, value), do: balance < value
end
