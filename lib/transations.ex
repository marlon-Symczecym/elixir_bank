defmodule Transations do
  defstruct date: nil, type: nil, value: nil, from: nil, to: nil

  @account_path "files"
  @register_file %{
    :transation => "#{@account_path}/transations.txt"
  }

  def register(type, from, value, date, to \\ nil) do
    (search_all() ++
       [%__MODULE__{type: type, from: from, value: value, date: date, to: to}])
    |> :erlang.term_to_binary()
    |> BankHelpers.write(@register_file[:transation])
  end

  def calculate_year(year) do
    {year |> search_year(), year |> search_year() |> calculate_values()}
  end

  def calculate_month(year, month) do
    {search_month(year, month), calculate_values(search_month(year, month))}
  end

  def calculate_day(year, month, day) do
    {search_day(year, month, day), calculate_values(search_day(year, month, day))}
  end

  def calculate_values(transations) do
    Enum.reduce(transations, 0, fn x, acc -> acc + x.value end)
  end

  def search_all(), do: search_transations()

  defp search_year(year) do
    search_all()
    |> Enum.filter(&(&1.date.year == year))
  end

  defp search_month(year, month) do
    search_all()
    |> Enum.filter(&(&1.date.year == year && &1.date.month == month))
  end

  defp search_day(year, month, day) do
    search_all()
    |> Enum.filter(&(&1.date.year == year && &1.date.month == month && &1.date.day == day))
  end

  defp search_transations() do
    BankHelpers.read(@register_file[:transation])
  end
end
