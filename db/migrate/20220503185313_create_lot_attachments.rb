class CreateLotAttachments < ActiveRecord::Migration[5.2]
  def change
    create_table :lot_attachments do |t|
      t.references :lot, foreign_key: true
      t.references :supplier, foreign_key: true
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
