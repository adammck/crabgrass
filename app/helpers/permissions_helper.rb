module PermissionsHelper

  # returns +true+ if the +current_user+ is allowed to perform +action+ in
  # +controller+, optionally with some arguments.
  #
  # permissions are resolved in this order:
  #
  # (1) check to see if a method is defined that matches may_action_controller?()
  # (2) check the class hierarchy for such a method (replacing controller name
  #     with the appropriate controller).
  # (3) fall back to default_permission
  # (4) return false if we had no success so far.
  #
  def may?(controller, action, *args)
    if controller.is_a?(Symbol)
      permission = send("may_#{action}_#{controller.to_s}?", *args)
    else
      method = permission_method_for_controller(controller, action)
      permission = controller.send(method, *args)
    end

    if permission and block_given?
      # return nil, if yield returns false
      yield
    else
      permission or nil
    end
  end

  def default_permission(*args)
    false
  end

  # shortcut for +may?+ but automatically selecting the current controller.
  # only use this in authorized? and similar situations where the user is
  # actually trying to do the action. It may display error messages if the
  # user may not take that action.
  # Use may? or link_if_may or the permission method itself to determine if
  # a user may theoretically do something (in order to display the link for
  # example)
  def may_action?(action, *args, &block)
    permission = may?(controller, action, *args, &block)
    if !permission and @error_message
      flash_message_now :error => @error_message
    end
    permission
  end

  # Generate a link to the specific action if the user is allowed to do
  # so, skipping it otherwise.
  #
  # Examples:
  #   <%= link_if_may("Create a Group", :group, :create) %>
  #   <%= link_if_may("Edit this Group", :group, :edit, @group) %>
  #   <%= link_if_may("Delete this Group", :group, :delete, @group, :confirm => "Are you sure?") %>
  #   <%= link_if_may("Boldly go", :warp_drive, :enable, nil, {}, {:style => "font-weight: bold;"} %>
  def link_if_may(link_text, controller, action, object = nil, link_opts = {}, html_opts = nil)
    if may?(controller, action, object)
      link_to(link_text, {:controller => controller, :action => action, :id => object.nil? ? nil : object.name}.merge(link_opts), html_opts)
    end
  end

  def link_to_active_if_may(link_text, controller, action, object = nil, link_opts = {}, active=nil)
    if may?(controller, action, object)
      link_to_active(link_text, {:controller => controller.to_s, :action => action, :id => object.nil? ? nil : object.name}.merge(link_opts), active)
    end
  end

  # matches may_x?
  PERMISSION_METHOD_RE = /^may_([_a-zA-Z]\w*)\?$/

  # call may?() if the missing method is in the form of a permission test (may_x?)
  def method_missing(method_id, *args)
    match = PERMISSION_METHOD_RE.match(method_id.to_s)
    if match
      may?(controller, match[1], *args)
      
      # i am removing this because i can't imagine what it is supposed to do -e
      #if /([_a-zA-Z]\w*)_#{controller.controller_name}/.match(match[1])
      #  super
      #else
      #  may?(controller, match[1], *args)
      #end
    else
      super
    end
  end
  
  private

  # this will try and use the may_action_controller? methods in the following
  # order:
  # 1) the controller name:
  #    asset_controller -> asset
  # 2) the name of the controllers parent namespace:
  #    me/trash_controller -> me
  # 3) the name of the controller's super class:
  #    event_page_controller -> base_page
  # 4) ensure "base_page" is in there somewhere if controller descends from it
  #    (the controller might be a subclass of a subclass of base page)
  def permission_method_for_controller(controller, action)
    names=[]
    names << controller.controller_name
    names << controller.controller_path.split("/")[-2]
    names << controller.class.superclass.controller_name
    names << 'base_page' if controller.is_a? BasePageController
    names.compact.each do |name|
      method="may_#{action}_#{name}?"
      return method if controller.respond_to?(method)
    end
    return 'default_permission'
  end
end
