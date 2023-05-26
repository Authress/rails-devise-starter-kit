# Authress Starter Kit: Ruby Rails using Devise

A repository that contains a Ruby on Rails example that uses [Authress](https://authress.io) via the Devise gem to login.

## Getting Started
The repository is a simple example using Ruby on Rails. Using the Devise gem and some additional ones the repo add Login with Authress. If you already have a Rails project running with Devise, you can use this repo as an example template and jump down to the [Configuration Section](#configuration) to see what updates should be made to your project to get it from just using Devise to using Devise with Authress.

### Running this project
This repo uses ruby `bundler` to install dependencies:

```sh
gem install bundler rails
bundle install
# Starts the server
bundle exec rails server
```

## Configuration

### 1. Install Omniauth and Authress SDK

Add to your Gemfile
```rb
gem "devise"
gem "omniauth"
gem "authress-sdk"
gem 'omniauth-rails_csrf_protection'
```

### 2. Include `:omniauthable` attribute to the app model
Where ever you have defined `devise` add the `:omniauthable` attribute to the configuration. This should already be set, but if it isn't, remember to add the necessary attributes:
* include `omniauth_providers: %i[authress]`

```rb
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :omniauthable, omniauth_providers: %i[authress]
end
```

In `config/routes.rb`:

```rb
Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

  root to: "home#index" 
end
```

### 3. Add the Authress OmniAuth configuration

Create the `config/initializers/authress.rb` file:

```rb
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

```

### 4. Add a callback controller

Login success! But now we need to populate our internal devise User model. Depending on how you implemented this it might be as easy as calling `User.from_omniauth(...)`

In `app/controllers/users/omniauth_callbacks_controller.rb`:

```rb
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def authress
    # The user has successfully logged in now with omniauth, but needs to be converted to your user model.
    # So implement this method in your User Model (e.g. app/models/user.rb) so that the @user is populated with the data that you need
    if false
      @user = User.from_omniauth(request.env['omniauth.auth'])

      if @user.persisted?
        flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', kind: 'Authress'
        sign_in_and_redirect @user, event: :authentication
      else
        session['devise.authress_user_data'] = request.env['omniauth.auth'].except('extra') # Removing extra as it can overflow some session stores
        redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
      end
    end

    render inline: \
    <<~HTML
      <div>You have successfully logged in using Authress</div>
      <br>
      <div>User Data Hash:</div>
      <pre>#{JSON.pretty_generate(request.env['omniauth.auth'])}</pre>
      <br>
    HTML

  end

  def failure
    # Handles failed authentication -- Show a failure page (you can also handle with a redirect)
    render inline: \
    <<~HTML
      <div>You reached this page due to an error in your OmniAuth configuration. Check the server logs</div>
      <div>Strategy: #{params['strategy']}</div>
      <div>Message: #{params['message']}</div>
      <br>
      <div>Url Querystring Data: #{params}</div>
      <br>
      <br>
      <%= button_to "Try Again", user_authress_omniauth_authorize_path, method: :post %>
      <br>
    HTML
  end
end
```

### 5. Add a login button your webpage

In any view where you would like a login button add it directly there:

```rb
<%= button_to "Sign in with your Corporate identity using Authress", user_authress_omniauth_authorize_path, method: :post %>
```