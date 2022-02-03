RSpec.shared_examples 'services/concerns/notifications/notification_mailer' do |times|
  describe 'notification_mailer' do
    let(:time) { times || 1 }
    let(:notification) { create(:notification) }

    before do
      allow(::NotificationMailer).to receive_message_chain(:notification_email, :deliver_later)
      allow(Notification).to receive(:create).and_return(notification_response)

      service.call
    end

    context 'when created notification' do
      let(:notification_response) { notification }

      it { expect(::NotificationMailer).to have_received(:notification_email).exactly(time).times }
    end

    context 'when not created notification' do
      let(:notification_response) { nil }

      it { expect(::NotificationMailer).not_to have_received(:notification_email) }
    end
  end

end