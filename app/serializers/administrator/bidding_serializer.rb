module Administrator
  class BiddingSerializer < ActiveModel::Serializer
    include BiddingSerializable

    attributes :spreadsheet_report, :subclassifications

    def spreadsheet_report
      object.spreadsheet_report.try(:file).try(:url)
    end

    def subclassifications
      object.classifications.map do |classification|
        ClassificationSerializer.new(classification)
      end
    end
  end
end
