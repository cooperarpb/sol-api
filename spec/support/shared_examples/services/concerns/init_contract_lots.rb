RSpec.shared_examples 'services/concerns/init_contract_lot' do |status|
  include_examples 'services/concerns/init_bidding_lot'

  let(:new_contract_status) { status&.dig(:contract_status) || :signed }

  let!(:contract) do
    create(:contract, proposal: proposal_c_lot_1, status: new_contract_status, user: user, user_signed_at: DateTime.current)
  end
end
