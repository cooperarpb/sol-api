require "rails_helper"

RSpec.describe NotificationMailer, type: :mailer do
  describe 'notification_email' do
    let(:notification) do 
      create(:notification, action: 'proposal.supplier_accepted', 
                            data: {"body_args"=>["Lote 01"], "extra_args"=>{"bidding_id"=>79}, "title_args"=>nil})
    end
    let(:email)         { described_class.notification_email(notification) }
    let(:email_subject) { I18n.t('notifications.proposal.supplier_accepted.title') }
    let(:email_body) do
      ActionView::Base.full_sanitizer.sanitize(I18n.t('notifications.proposal.supplier_accepted.body') % notification.body_args)
    end

    it 'renders the subject' do
      expect(email.subject).to eql(email_subject)
    end
  
    it 'renders the receiver' do
      expect(email.to).to eql([notification.receivable.email])
    end
  
    it 'renders the sender' do
      expect(email.from).to eql(['no-reply@example.com'])
    end

    it 'renders body' do
      expect(email.body).to include(email_body)
    end
  end
end
