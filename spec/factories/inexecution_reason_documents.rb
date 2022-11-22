FactoryBot.define do
  factory :inexecution_reason_document do
    file Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/myfiles/file.pdf')))
  end
end
