class Bidding::Minute::PdfRegenerateWorker
  include Sidekiq::Worker

  sidekiq_options retry: 5

  def perform(bidding_id)
    bidding = Bidding.find(bidding_id)
    BiddingsService::Minute::PdfRegenerate.call!(bidding: bidding)
  end
end
