# CG - Provides stream-lined login capabilities for client applications.

class LoginController < ApplicationController

  # Since dealing with sensitive data we use SSL
  force_ssl

  # GET /login
  # GET /login.json
  def check_login

    # CG - Currently we are only supporting JSON formats (server-client communication format)
    respond_to do |format|

      # CG - Check that the credentials passed can be used to log in, and return if the account is an admin or not. (Will return HTTP 401 if user does not exist/credentials are incorrect)
      format.json { render :partial => "users/login.json.erb", :locals => {:admin => is_admin?, :id => current_user.id}}

    end

  end

end
