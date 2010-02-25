class Me::MessagePostsController < Me::BaseController
  prepend_before_filter :fetch_recipient

  def create
    in_reply_to = Post.find_by_id(params[:in_reply_to_id])
    current_user.send_message_to!(@recipient, params[:post][:body], in_reply_to)

    respond_to do |wants|
      wants.html { redirect_to message_path(@recipient.login) }
      wants.js { render :nothing => true }
    end
  end

  protected

  def fetch_recipient
    @recipient = User.find_by_login(params[:message_id])
    redirect_to messages_path if @recipient.blank?
  end

  def authorized?
    if current_user == @recipient
      flash_message :error => I18n.t(:message_to_self_error)
      redirect_to messages_path
    elsif !@recipient.may_be_pestered_by?(current_user)
      flash_message :error => I18n.t(:message_cant_perster_error, :user => @recipient.name)
      redirect_to messages_path
    end

    true
  end
end
