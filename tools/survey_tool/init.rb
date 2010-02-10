PageClassRegistrar.add(
  'SurveyPage',
  :controller => 'survey_page',
  :icon => 'page_survey',
  :class_group => 'vote',
  :order => 4
)

require File.join(File.dirname(__FILE__), 'lib',
                  'survey_user_extension')

Dispatcher.to_prepare do
  apply_mixin_to_model(User, SurveyUserExtension)
end

#self.override_views = true
self.load_once = false
