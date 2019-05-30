json.extract! expense, :id, :value, :date, :created_at, :updated_at
json.url expense_url(expense, format: :json)
