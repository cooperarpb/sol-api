# Classe reponsável por enviar e-mail com o mesmo conteúdo das notificações
class NotificationMailer < ApplicationMailer

  default from: "SOL <nao-responda@car.ba.gov.br>"

  # Envia e-mail com o mesmo título e mensagem da notificação informada para o destinatário informado.
  # 
  # @param notification [Model]
  #        Notificação na qual serão utilizados o titulo e o corpo da mensagem no e-mail.
  def notification_email(notification)
    @subject  = locale_sanitize(notification, :title, notification.title_args)
    @body     = locale_sanitize(notification, :body,  notification.body_args)
    @receiver = notification.receivable

    mail(to: @receiver&.email, subject: @subject)
  end

  private

  def locale_sanitize(notification, field, args)
    receivable = notification.receivable
    action     = notification.action

    I18n.with_locale(receivable.locale) do
      sanitize(I18n.t("notifications.#{action}.#{field}") % args)
    end
  end

  def sanitize(html)
    ActionView::Base.full_sanitizer.sanitize(html)
  end
end
