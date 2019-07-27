class AddFlagForIssueItem < ActiveRecord::Migration[5.1]
  def change
  	add_column :issue_items, :flag, :integer
  end
end
