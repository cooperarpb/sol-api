class CreateBiddingsAndInexecutionReasonDocuments < ActiveRecord::Migration[5.2]
  def change
    create_table :biddings_and_inexecution_reason_documents do |t|
      t.references :bidding, foreign_key: true
      t.references :inexecution_reason_document, foreign_key: {to_table: :inexecution_reason_documents}, index: { name: 'index_baird_on_inexecution_reason_document_id' }
    end
  end
end
