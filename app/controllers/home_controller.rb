class HomeController < ApplicationController

  DESIGNS_PER_COMPETITION_PAGE = 5

  def index
  end

  def leaderboard
    @designs = Design.for_competition.includes(:user).precount(:votes).sort { |designA, designB|
      designB.votes.count <=> designA.votes.count
    }.first(10)
  end

  def competition
    @designs = Design.for_competition.includes(:user).precount(:votes).page(params[:page]).per(DESIGNS_PER_COMPETITION_PAGE)
  end

  def contact
    @message = Message.new
  end

  def design_guide
    design_guide = File.join(Rails.root, 'public', 'design_guide.pdf')
    send_file(design_guide, filename: 'design_guide.pdf', disposition: 'inline', type: 'application/pdf')
  end

  def contact_us
    @message = new_message
    if @message.save
      UserMailer.contact_us(@message).deliver
      redirect_to contact_us_path, notice: 'Message sent successfully'
    else
      render :contact, notice: 'Sorry, your message could not be sent. please try again'
    end
  end

  def robots
    headers['Content-Type'] = Mime[:text].to_s
    request.format = :txt
    render(
      plain: '', # nothing - all content in layout file
      layout: '/layouts/robots',
      formats: 'txt')
  end

  private

  def message_params
    params.require(:message).permit(:name, :email, :message)
  end

  def new_message
    Message.new(message_params)
  end

end
