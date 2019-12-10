class AddIllIdForNote < ActiveRecord::Migration[5.1]
  def change
  	add_column :notes, :ill_id,:integer
  end
end
