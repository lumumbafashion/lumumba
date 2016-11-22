class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml with the following lookup: en.user_mailer.contact_us.subject

  layout 'mailer'

  def contact_us(message)
    @message = message
    mail to: 'tribe@lumumba.com', from: message.email, subject: "Message from Contact Us form - #{message.email}"
  end

  def first_vote_notification(design)
    @design = design
    mail to: @design.user.email, from: 'notifications@lumumba.com', subject: "Design ##{design.id} - You just got your first vote!"
  end

  def purchase_confirmation(order)
    @order = order
    @address = order.address.try(:to_s).presence
    mail to: @order.user.email, from: 'notifications@lumumba.com', subject: "Order confirmation ##{order.id}- Thanks for shopping with Lumumba!"
  end

end
