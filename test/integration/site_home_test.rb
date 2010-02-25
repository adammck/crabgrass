require "#{File.dirname(__FILE__)}/../test_helper"

class SiteHomeTest < ActionController::IntegrationTest

  def setup
    enable_site_testing
  end

  def teardown
    disable_site_testing
  end

  def test_hide_show_welcome_message
    login 'blue'
    visit '/'

    assert_contain "See Tips to get started"
    assert_have_no_selector "#welcome_box table"

    visit '/?welcome_box=1'

    assert_contain "Hide Tips"
    assert_have_selector "#welcome_box table"

    # hide the welcome again
    visit '/'

    assert_contain "See Tips to get started"
    assert_not_contain "Hide Tips"
    assert_have_no_selector "#welcome_box table"
  end

end
