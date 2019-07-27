class CreateIssueItems < ActiveRecord::Migration[5.1]
  def change
    create_table :issue_items do |t|
      t.string :answer
      t.integer :issue_id
      t.integer :next_issue_id
      t.integer :result

      t.timestamps
    end
  end
end
