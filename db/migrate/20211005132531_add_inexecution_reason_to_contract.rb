class AddInexecutionReasonToContract < ActiveRecord::Migration[5.2]
  def change
    add_column :contracts, :inexecution_reason, :text
  end
end
