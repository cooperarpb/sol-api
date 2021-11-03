class AddMergedInexecutionReasonDocumentToBiddings < ActiveRecord::Migration[5.2]
  def change
    add_reference :biddings, :merged_inexecution_reason_document, index: true, foreign_key: {to_table: :inexecution_reason_documents}
  end
end
