class CreateExpenses < ActiveRecord::Migration[5.1]
  def change
    create_table :expenses do |t|
      t.float :value
      t.date :date

      t.timestamps
    end
  end
end
