class HomeController < ApplicationController
  def index
    total_expenses = Expense.sum(:value)
    total_incomes = Income.sum(:value)
    @cash_balance = total_incomes - total_expenses

    expenses_by_month = Expense.group("(extract(year from date))::integer").group('(EXTRACT(MONTH FROM date))::integer').sum(:value)
    incomes_by_month = Income.group("(extract(year from date))::integer").group('(EXTRACT(MONTH FROM date))::integer').sum(:value)
    normalize_charts_keys expenses_by_month, incomes_by_month
    balance_by_month_map = {}

    incomes_by_month.keys.each do |key|
      balance_by_month_map[key] = incomes_by_month[key] - expenses_by_month[key]
    end

    prepared_expenses_by_month = prepare_keys(expenses_by_month)
    prepared_incomes_by_month = prepare_keys(incomes_by_month)
    prepared_balance_by_month = prepare_keys(balance_by_month_map)

    @expenses_incomes_data = [
      {name: "Receitas", data: prepared_incomes_by_month},
      {name: "Despesas", data: prepared_expenses_by_month},
    ]
    @balance_data = prepared_balance_by_month

    respond_to do |format|
      format.html { render }
      format.json { render json: { 
        cash_balance: ActionController::Base.helpers.number_to_currency(@cash_balance),
        expenses_incomes_data: @expenses_incomes_data,
        balance_data: @balance_data
       }}
    end
  end

  private
    def normalize_charts_keys(chart1, chart2)
      chart1.keys.each do |key|
        chart2[key] = 0 unless chart2.has_key? key
      end
      chart2.keys.each do |key|
        chart1[key] = 0 unless chart1.has_key? key
      end
    end

    def prepare_keys(hash)
      months = %w(Jan Fev Mar Abr Mai Jun Jul Ago Set Out Nov Dez) 
      hash
        .keys
        .sort
        .map do |key|
          value = hash[key]
          ["#{months[key[1] - 1]}/#{key[0]}", value]
        end
    end
end