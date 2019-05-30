class HomeController < ApplicationController
  def index
    total_expenses = Expense.sum(:value)
    total_incomes = Income.sum(:value)
    @cash_balance = total_incomes - total_expenses
  end
end