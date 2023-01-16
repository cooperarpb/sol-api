RSpec.shared_examples 'services/concerns/notifications/fcm' do |times|
  let(:time) { times || 1 }

  describe 'fcm' do
    let(:notification) { create(:notification) }
    let(:fcm_response) { double('call', call: true) }
    let(:send_fcm_notification) { true }

    before do
      allow(::Notifications::Fcm).to receive(:delay).and_return(fcm_response)
      allow(Notification).to receive(:create).and_return(notification_response)
      # XXX: A configuração do envio de push notification para a PB não é possível no momento,
      # pois a atualização da gem fcm entra em conflito com outras gems que utilizam
      # versões diferentes da gem Faraday.
      # Assim que o sistema puder ser atualizado e testado, a funcionalidade poderá ser validada novamente.
      allow(service).to receive(:send_fcm_notification).and_return(send_fcm_notification)

      service.call
    end

    context 'when created notification' do
      let(:notification_response) { notification }

      it { expect(::Notifications::Fcm).to have_received(:delay).exactly(time).times }
    end

    context 'when not created notification' do
      let(:notification_response) { nil }

      it { expect(::Notifications::Fcm).not_to have_received(:delay) }
    end

    context 'when send_fcm_notification param is false' do
      let(:send_fcm_notification) { false }
      let(:notification_response) { notification }

      it { expect(::Notifications::Fcm).not_to have_received(:delay) }
    end
  end
end
