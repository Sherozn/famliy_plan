class CreateIlls < ActiveRecord::Migration[5.1]
  def change
    create_table :ills do |t|
      t.string :name
      t.integer :status
      t.integer :rank, default: 0

      t.timestamps
    end
  end
end
