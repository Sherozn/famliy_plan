class CreateComments < ActiveRecord::Migration[5.1]
  def change
    create_table :comments do |t|
      t.integer :insurance_id
      t.integer :disease_id
      t.integer :status, default: 0
      t.text :remark

      t.timestamps
    end
  end
end
