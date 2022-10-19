require 'rails_helper'

RSpec.describe Administrator::BiddingSerializer, type: :serializer do
  it_behaves_like 'a bidding_serializer' do
    describe 'extra attributes' do
      describe 'spreadsheet_report' do
        let(:spreadsheet_report) { create(:spreadsheet_document) }
        let(:object) do
          create :bidding, merged_minute_document: merged_minute_document,
                           edict_document: edict_document,
                           spreadsheet_report: spreadsheet_report
        end
  
        it { expect(subject['spreadsheet_report']).to include('.xls')}
      end

      describe 'subclassifications' do
        let(:object) { create :bidding }

        let!(:subclassification) { create(:classification, classification: object.classification) }

        let(:serialized_subclassifications) do
          object.classifications.map { |subclassification| format_json(ClassificationSerializer, subclassification) }
        end
  
        it { expect(subject['subclassifications']).to eq serialized_subclassifications }
      end
    end
  end
end
