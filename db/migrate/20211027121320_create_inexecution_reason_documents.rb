class CreateInexecutionReasonDocuments < ActiveRecord::Migration[5.2]
  def change
    create_table :inexecution_reason_documents do |t|
      t.string :file

      t.timestamps
    end
  end
end
