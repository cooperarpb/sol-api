require 'rails_helper'

RSpec.describe Notifications::Contracts::SupplierSignature::CloseToDeadline, type: [:service, :notification] do
  include_examples 'services/concerns/init_contract'

  let(:lot_proposal) { create(:lot_proposal, proposal: proposal, supplier: supplier) }
  let(:provider) { create(:provider, type: 'Provider') }
  let!(:contract) do
    create(:contract, proposal: proposal,
                      supplier: supplier, supplier_signed_at: DateTime.current)
  end
  let(:params) { { contract: contract } }
  let(:service) { described_class.new(params) }

  before do
    proposal.lot_proposals << lot_proposal
  end

  describe '#initialize' do
    subject { service }

    it { expect(subject.contract).to eq contract }
  end

  describe '.call' do
    subject { described_class.call(params) }

    describe 'count' do
      it { expect{ subject }.to change{ Notification.count }.by(1) }
    end

    describe 'notification' do
      let(:notification) { Notification.where(receivable: receivable).take }

      before { subject }

      describe 'suppliers notification' do
        let(:receivable) { supplier }

        it { expect(notification.receivable).to eq supplier }
        it { expect(notification.notifiable).to eq contract }
        it { expect(notification.action).to eq 'contract.supplier_signature_close_to_deadline' }
        it { expect(notification.read_at).to be_nil }

        describe 'args' do
          let(:extra_args) { { bidding_id: bidding.id }.as_json }

          it { expect(notification.extra_args).to eq extra_args }
          it { expect(notification.body_args).to eq contract.title }
        end

        describe 'I18n' do
          let(:title_msg) { 'Prazo a encerrar!' }
          let(:body_msg) do
            "O prazo para assinatura do contrato "\
            "<strong>#{contract.title}</strong> encerra <strong>amanhã</strong>."
          end
          let(:key) { "notifications.#{notification.action}" }
          let(:title) { I18n.t("#{key}.title") % notification.title_args }
          let(:body) { I18n.t("#{key}.body") % notification.body_args }

          it { expect(title).to eq(title_msg) }
          it { expect(body).to eq(body_msg) }
        end
      end
    end

    it_should_behave_like 'services/concerns/notifications/fcm', 1

    it_should_behave_like 'services/concerns/notifications/notification_mailer', 1
  end
end
