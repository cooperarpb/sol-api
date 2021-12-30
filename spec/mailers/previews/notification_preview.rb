# Preview all emails at http://localhost:3000/rails/mailers/notification
class NotificationPreview < ActionMailer::Preview
  def notification_email
    notification = Notification.last
    NotificationMailer.notification_email(notification)
  end
end
