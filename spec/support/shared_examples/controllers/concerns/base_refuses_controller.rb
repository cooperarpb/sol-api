RSpec.shared_examples "controllers/concerns/base_refuses_controller" do |key|
  describe 'bidding_failure_service' do
    let(:bidding_service_failure_params) do
      { 
        bidding: bidding,
        creator: user,
        comment: Events::ProposalStatusChange.where(eventable: bidding.proposals).map(&:comment).join('. ')
      }
    end

    before do
      allow(BiddingsService::Failure).to receive(:call).with(bidding_service_failure_params) { true }
    end

    context 'when all lots from proposal`s bidding have failure status' do
      context 'and BiddingsService::Failure returns true' do            
        before do
          allow_any_instance_of(Bidding).to receive(:fully_refused_proposals?).and_return(true) 

          post_update
        end

        it { expect(response).to have_http_status :ok }
        it { expect(BiddingsService::Failure).to have_received(:call).with(bidding_service_failure_params) }
      end

      context 'and BiddingsService::Failure returns false' do
        before do
          allow(BiddingsService::Failure).to receive(:call).with(bidding_service_failure_params) { false }
          allow_any_instance_of(Bidding).to receive(:fully_refused_proposals?).and_return(true) 

          post_update
        end

        it { expect(response).to have_http_status :unprocessable_entity }
        it { expect(BiddingsService::Failure).to have_received(:call).with(bidding_service_failure_params) }
      end
    end

    context 'when not all lots from proposal`s bidding have failure status' do
      before do 
        allow_any_instance_of(Bidding).to receive(:fully_refused_proposals?).and_return(false) 
        
        post_update
      end

      it { expect(response).to have_http_status :ok }
      it { expect(BiddingsService::Failure).not_to have_received(:call) }
    end
  end
end