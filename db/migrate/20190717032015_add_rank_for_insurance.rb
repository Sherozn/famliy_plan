class AddRankForInsurance < ActiveRecord::Migration[5.1]
  def change
  	add_column :insurances, :factory, :string
  	add_column :insurances, :platform, :integer
  end
end
