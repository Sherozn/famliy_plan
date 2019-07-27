class CreateIssues < ActiveRecord::Migration[5.1]
  def change
    create_table :issues do |t|
      t.string :content
      t.string :insurance_ids
      t.integer :disease_id
      t.integer :rank
      t.string :iss_ids

      t.timestamps
    end
  end
end
