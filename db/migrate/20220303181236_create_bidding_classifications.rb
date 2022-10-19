class CreateBiddingClassifications < ActiveRecord::Migration[5.2]
  def change
    create_table :bidding_classifications do |t|
      t.references :bidding, foreign_key: true, index: true
      t.references :classification, foreign_key: true, index: true

      t.timestamps
    end
  end
end
