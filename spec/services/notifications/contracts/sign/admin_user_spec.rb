require 'rails_helper'

RSpec.describe Notifications::Contracts::Sign::AdminUser, type: [:service, :notification] do
  include_examples 'services/concerns/init_contract'

  let(:covenant) { bidding.covenant }
  let(:cooperative) { covenant.cooperative }
  let(:user) { create(:user, cooperative: cooperative) }
  let(:admin) { create(:admin) }
  let!(:contract) do
    create(:contract, proposal: proposal,
                      user: user, user_signed_at: DateTime.current,
                      supplier: supplier, supplier_signed_at: DateTime.current)
  end
  let(:params) { { contract: contract } }
  let(:service) { described_class.new(params) }

  describe '#initialize' do
    subject { service }

    it { expect(subject.contract).to eq contract }
  end

  describe '.call' do
    subject { described_class.call(params) }

    describe 'count' do
      it { expect{ subject }.to change{ Notification.count }.by(2) }
    end

    describe 'notification' do
      let(:notification) { Notification.where(receivable: receivable).take }

      before { subject }

      describe 'admin notification' do
        let(:receivable) { bidding.admin }

        it { expect(notification.receivable).to eq bidding.admin }
        it { expect(notification.notifiable).to eq contract }
        it { expect(notification.action).to eq 'contract.sign_admin_user' }
        it { expect(notification.read_at).to be_nil }

        describe 'args' do
          let(:extra_args) { { bidding_id: bidding.id }.as_json }

          it { expect(notification.extra_args).to eq extra_args }
          it { expect(notification.body_args).to eq [contract.title, bidding.title, supplier.name] }
        end

        describe 'I18n' do
          let(:title_msg) { 'Contrato assinado pelo fornecedor.' }
          let(:body_msg) do
            "O contrato <strong>#{contract.title}</strong> da licitação <strong>#{bidding.title}</strong> foi "\
            "assinado pelo fornecedor <strong>#{supplier.name}</strong>"
          end
          let(:key) { "notifications.#{notification.action}" }
          let(:title) { I18n.t("#{key}.title") % notification.title_args }
          let(:body) { I18n.t("#{key}.body") % notification.body_args }

          it { expect(title).to eq(title_msg) }
          it { expect(body).to eq(body_msg) }
        end
      end

      describe 'users notification' do
        let(:receivable) { user }

        it { expect(notification.receivable).to eq user }
        it { expect(notification.notifiable).to eq contract }
        it { expect(notification.action).to eq 'contract.sign_admin_user' }
        it { expect(notification.read_at).to be_nil }

        describe 'args' do
          let(:extra_args) { { bidding_id: bidding.id }.as_json }

          it { expect(notification.extra_args).to eq extra_args }
          it { expect(notification.body_args).to eq [contract.title, bidding.title, supplier.name] }
        end

        describe 'I18n' do
          let(:title_msg) { 'Contrato assinado pelo fornecedor.' }
          let(:body_msg) do
            "O contrato <strong>#{contract.title}</strong> da licitação <strong>#{bidding.title}</strong> foi "\
            "assinado pelo fornecedor <strong>#{supplier.name}</strong>"
          end
          let(:key) { "notifications.#{notification.action}" }
          let(:title) { I18n.t("#{key}.title") % notification.title_args }
          let(:body) { I18n.t("#{key}.body") % notification.body_args }

          it { expect(title).to eq(title_msg) }
          it { expect(body).to eq(body_msg) }
        end
      end
    end

    it_should_behave_like 'services/concerns/notifications/fcm', 2

    it_should_behave_like 'services/concerns/notifications/notification_mailer', 2
  end
end
