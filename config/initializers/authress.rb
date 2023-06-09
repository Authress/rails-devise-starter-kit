require 'authress-sdk'

AuthressSdk.configure do |config|
  # create an instance of the API class during service initialization
  # Replace the base_url with the custom Authress domain for your account
  # https://authress.io/app/#/settings?focus=domain
  config.base_url = 'https://login.company.com'
end

if AuthressSdk::AuthressClient.default.base_url == 'https://login.company.com'
  raise "Please set the Authress base_url in the authress.rb initializer to your custom domain. The custom domain can be configured at https://authress.io/app/#/settings?focus=domain"
end

Rails.application.config.middleware.use OmniAuth::Builder do
  # Application ID generated in Authress dashboard (https://authress.io/app/#/settings?focus=applications)
  # You can either use the default app `app_default` or create a new one
  provider :authress, :application_id => 'app_default'
end