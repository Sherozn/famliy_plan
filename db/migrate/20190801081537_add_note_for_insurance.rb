class AddNoteForInsurance < ActiveRecord::Migration[5.1]
  def change
  	add_column :insurances, :note, :text
  end
end
