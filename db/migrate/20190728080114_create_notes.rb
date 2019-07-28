class CreateNotes < ActiveRecord::Migration[5.1]
  def change
    create_table :notes do |t|
      t.string :name
      t.integer :insurance_id
      t.integer :product_type
      t.integer :rank
      t.text :note

      t.timestamps
    end
  end
end
