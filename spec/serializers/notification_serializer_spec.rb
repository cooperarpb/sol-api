require 'rails_helper'

RSpec.describe NotificationSerializer, type: :serializer do
  let(:object) { create(:notification, read_at: DateTime.now, data: { "body_args" => ['Mensagem'] }) }

  subject { format_json(described_class, object) }

  describe 'attributes' do
    let(:title) { I18n.t("notifications.#{object.action}.title") % object.title_args }
    let(:body) { I18n.t("notifications.#{object.action}.body") % object.body_args }

    it { is_expected.to include 'id' => object.id }
    it { is_expected.to include 'action' => object.action }
    it { is_expected.to include 'read_at' => object.read_at.rfc2822 }
    it { is_expected.to include 'created_at' => object.created_at.rfc2822 }
    it { is_expected.to include 'title' => title }
    it { is_expected.to include 'body' => body }
    it { is_expected.to include 'notifiable_id' => object.notifiable_id }
    it { is_expected.to include 'args' => object.extra_args }

    context 'When body_args are not present' do
      let(:object) { create(:notification, read_at: DateTime.now, data: { "title_args" => ['Título'] }) }

      subject { format_json(described_class, object) }

      it { is_expected.to include 'body' => I18n.t('notifications.common_messages.body_error') }
    end
  end
end
