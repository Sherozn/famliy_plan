class CreateInsurances < ActiveRecord::Migration[5.1]
  def change
    create_table :insurances do |t|
      t.integer :code
      t.string :name
      t.integer :status, default: 0
      t.integer :product_type
      t.integer :rank

      t.timestamps
    end
  end
end
