module Coop
  class LotAttachmentSerializer < ActiveModel::Serializer
    attributes :id, :lot_id, :status, :attachment_file, :attachment_filename, :supplier_name, :lot_name

    def attachment_file
      object.attachment&.file
    end

    def attachment_filename
      object.attachment&.file&.file&.filename
    end

    def supplier_name
      object.supplier&.name
    end

    def lot_name
      object.lot&.name
    end
  end
end
