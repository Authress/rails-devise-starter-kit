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