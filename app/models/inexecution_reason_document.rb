class InexecutionReasonDocument < ApplicationRecord
  has_and_belongs_to_many :biddings, foreign_key: :inexecution_reason_document_id,
                                     association_foreign_key: :bidding_id,
                                     join_table: 'biddings_and_inexecution_reason_documents'

  validates_presence_of :file

  mount_uploader :file, DocumentUploader::Pdf
end
