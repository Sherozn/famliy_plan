class ChangeCodeForDisease < ActiveRecord::Migration[5.1]
  def change
  	change_column :diseases, :code, :string, :limit => 10
  end
end
