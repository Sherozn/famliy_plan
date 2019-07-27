class CreateRates < ActiveRecord::Migration[5.1]
  def change
    create_table :rates do |t|
      t.integer :insurance_id
      t.string :group
      t.integer :year
      t.integer :jf_year
      t.float :rate
      t.integer :age
      t.integer :sex
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
