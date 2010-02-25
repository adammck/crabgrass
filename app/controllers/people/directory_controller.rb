#
# A controller for the directory of users
#

class People::DirectoryController < People::BaseController

  layout 'directory'
  helper :people

  before_filter :login_required, :action => 'show'

  def index
    @users = User.on(current_site).recent.paginate :page => params[:page]
    @second_nav = 'all'
    @third_nav = 'discover'
  end

  def show
    if id?(:friends, :peers, :browse)
      self.send(params[:id])
    else
      render_permission_denied
    end
  end

  protected

  def friends
    @users = (User.friends_of(current_user).on(current_site).alphabetized(@letter_page)).paginate :page => params[:page]

    # what letters can be used for pagination
    @pagination_letters = (User.friends_of(current_user).on(current_site).logins_only).collect{|u| u.login.first.upcase}.uniq
    @second_nav = 'my'
  end

  def peers
    @users = User.peers_of(current_user).on(current_site).alphabetized(@letter_page).paginate :page => params[:page]
     # what letters can be used for pagination
    @pagination_letters = (User.peers_of(current_user).on(current_site).logins_only).collect{|u| u.login.first.upcase}.uniq
    @second_nav = 'peers'
  end

  def browse
    @users = User.on(current_site).alphabetized(@letter_page).paginate :page => params[:page]
    # what letters can be used for pagination
    @pagination_letters = (User.on(current_site).logins_only).collect{|u| u.login.first.upcase}.uniq
    @second_nav = 'all'
    @third_nav = 'browse'
  end

  protected

  def authorized?
    true
  end

  before_filter :prepare_pagination
  def prepare_pagination
    @letter_page = params[:letter] || ''
  end

  def context
    person_context
  end

end

