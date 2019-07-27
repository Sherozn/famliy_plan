class CreateDiseases < ActiveRecord::Migration[5.1]
  def change
    create_table :diseases do |t|
      t.integer :code
      t.string :name
      t.integer :rank
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
