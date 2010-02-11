#
#
# NOTE: make sure to update the validates_handle function whenever you add a new controller
# or a new root path route. This way, group and user handles will not be created for those
# (group name or user login are used as the :context in the default route, so it can't collide
# with any of our other routes).
#

ActionController::Routing::Routes.draw do |map|

  # total hackety magic:
#  map.filter 'crabgrass_routing_filter'

  ##
  ## PLUGINS
  ##

  # optionally load these plugin routes, if they happen to be loaded
  map.from_plugin :super_admin rescue NameError
  map.from_plugin :translator   rescue NameError
  map.from_plugin :moderation  rescue NameError

  map.namespace :admin do |admin|
    admin.resources :announcements
    admin.resources :email_blasts
    admin.resources :users, :only => [:new, :create]
    admin.resources :groups, :only => [:new, :create]
    admin.resources :custom_appearances, :only => [:edit, :update]
    admin.sites 'sites/:action', :controller => 'sites'
    admin.root :controller  => 'base'
  end

  ##
  ## ASSET
  ##

  map.connect '/assets/:action/:id',                :controller => 'assets', :action => /create|destroy/
  map.connect 'assets/:id/versions/:version/*path', :controller => 'assets', :action => 'show'
  map.connect 'assets/:id/*path',                   :controller => 'assets', :action => 'show'

  map.avatar 'avatars/:id/:size.jpg', :action => 'avatar', :controller => 'static'
  map.connect 'latex/*path', :action => 'show', :controller => 'latex'

  ##
  ## ME
  ##

  map.connect 'me/inbox/:action/*path',     :controller => 'me/inbox'
  # map.connect 'me/requests/:action/*path',  :controller => 'me/requests'
  map.connect 'me/search/*path',            :controller => 'me/search', :action => 'index'
  map.connect 'me/dashboard/:action/*path', :controller => 'me/dashboard'
  map.connect 'me/tasks/:action/*path',     :controller => 'me/tasks'
  map.connect 'me/infoviz.:format',         :controller => 'me/infoviz', :action => 'visualize'
  map.connect 'me/pages/trash/:action/*path',     :controller => 'me/trash'
  map.connect 'me/pages/trash',                   :controller => 'me/trash'


  map.with_options(:namespace => 'me/', :path_prefix => 'me') do |me|
    # This should only be index. However ajax calls seem to post not get...
    me.resource :flag_counts, :only => [:show, :create]
    me.resource :recent_pages, :only => [:show, :create]
    me.resource :my_avatar, :as => 'avatar', :controller => 'avatar', :only => :delete

    me.resources :requests, { :collection => { :mark => :put, :approved => :get, :rejected => :get }}
    # for now removing peers option until we work on fixing friends/peers distinction
    #me.resources :social_activities, :as => 'social-activities', :only => :index, :collection => { :peers => :get }
    me.resources :social_activities, :as => 'social-activities', :only => :index
    me.resources :messages, { :collection => { :mark => :put },
                               :member => { :next => :get, :previous => :get }} do |message|
      message.resources :posts, :controller => 'message_posts'
    end
    me.resources :public_messages, :only => [:show, :create, :destroy]


  end

  # HACK: pretend resources :path_names options works for :collection's and not just :member's
  # won't have to pretend anymore with rails 2.3.5
  map.my_work_me_pages '/me/pages/my-work', :action => "my_work", :controller => "pages", :conditions => {:method => :get}

  map.resource :me, :only => [:show, :edit, :update], :controller => 'me' do |me|
    me.resources :pages,
      :only => [:new, :update, :index],
      :collection => {
  #      :notification => :get,
        :all => :get,
        :mark => :put}
  end

  ##
  ## PEOPLE
  ##

  map.resources :people_directory, :as => 'directory', :path_prefix => 'people', :controller => 'people/directory'

  map.with_options(:namespace => 'people/') do |people_space|
    people_space.resources :people do |people|
      people.resources :messages, :as => 'messages/public', :controller => 'public_messages'
    end
  end

  map.connect 'person/:action/:id/*path', :controller => 'person'

  ##
  ## EMAIL
  ##

  map.connect '/invites/:action/*path', :controller => 'requests', :action => /accept/
  map.connect '/code/:id', :controller => 'codes', :action => 'jump'

  ##
  ## PAGES
  ##

  map.connect '/me/pages/*path', :controller => 'pages'

  # handle all the namespaced base_page controllers:
  map.connect ':controller/:action/:id', :controller => /base_page\/[^\/]+/
  #map.connect 'pages/search/*path', :controller => 'pages', :action => 'search'

  ##
  ## OTHER
  ##

  map.login 'account/login',   :controller => 'account',   :action => 'login'
  #map.resources :custom_appearances, :only => [:edit, :update]
  map.reset_password '/reset_password/:token', :controller => 'account', :action => 'reset_password'
  map.account_verify '/verify_email/:token', :controller => 'account', :action => 'verify_email'
  map.account '/account/:action/:id', :controller => 'account'

  map.connect '', :controller => 'root'

  map.connect 'bugreport/submit', :controller => 'bugreport', :action => 'submit'

  ##
  ## GROUP
  ##

  map.group_directory 'groups/directory/:action/:id', :controller => 'groups/directory'
  map.network_directory 'networks/directory/:action/:id', :controller => 'networks/directory'

  map.resources :groups do |group|
    group.resources :pages, :only => :new
  end

  map.connect 'groups/:action/:id', :controller => 'groups', :action => /search|archive|discussions|tags|trash|pages/
  map.connect 'groups/:action/:id/*path', :controller => 'groups', :action => /search|archive|discussions|tags|trash|pages/

  map.resources :networks do |network|
    network.resources :pages, :only => :new
  end

  map.connect 'networks/:action/:id', :controller => 'networks', :action => /search|archive|discussions|tags|trash/
  map.connect 'networks/:action/:id/*path', :controller => 'networks', :action => /search|archive|discussions|tags|trash/

  ##
  ## CHAT
  ##
  map.chat 'chat/:action/:id', :controller => 'chat'
  map.chat_archive 'chat/archive/:id/date/:date', :controller => 'chat', :action => 'archive'
#  map.connect 'chat/archive/:id/*path', :controller => 'chat', :action => 'archive'
  ##
  ## DEFAULT ROUTE
  ##

  map.connect ':controller/:action/:id'


  ##
  ## DISPATCHER
  ##

  map.connect 'page/:_page/:_page_action/:id', :controller => 'dispatch', :action => 'dispatch', :_page_action => 'show', :id => nil

  map.connect ':_context/:_page/:_page_action/:id', :controller => 'dispatch', :action => 'dispatch', :_page_action => 'show', :id => nil

  map.connect ':_context', :controller => 'dispatch', :action => 'dispatch', :_page => nil

  # i am not sure what this was for, but it breaks routes for committees. this
  # could be fixed by adding \+, but i am just commenting it out for now. -e
  # :_context => /[\w\.\@\s-]+/

end

