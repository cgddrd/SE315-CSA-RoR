class UsersController < ApplicationController
  # Since dealing with sensitive data we use SSL
  # Only destroy does not require SSL, all the others do

  force_ssl except: [:destroy]

  # CG - Ensure only Admins can create new users.
  before_action :admin_required, only: [:index, :search, :destroy, :create]
  before_action :set_current_page, except: [:index]
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  rescue_from ActiveRecord::RecordNotFound, with: :show_record_not_found



  def search
    # Use will_paginate's :conditions and :joins to search across both the
    # users and user_details tables. search_fields private method will add a field
    # for each checkbox field checked by the user, or returns nil
    # if none were checked. The search_conditions method is defined
    # in lib/searchable.rb and either searches across all columns identified in
    # User.searchable_by or uses the search_fields to constrain the search

    respond_to do |format|
      format.html {
        @users = User.where(User.search_conditions(params[:q], search_fields(User)))
                     .joins(:user_detail)
                     .paginate(page: params[:page],
                               per_page: params[:per_page])
                     .order('surname, firstname')

        render 'index'
      }

      # Deal with incoming Ajax request for JSON data for autocomplete search field
      format.json {

        # CG - Perform the search using the serach parameters passed via the URL
        @users = User.where(User.search_conditions(params[:q], search_fields(User))).joins(:user_detail).order('surname, firstname')

        # CG - If we are searching via the client application (and not the AJAX auto-complete form) then we need to use a different view template to return the required user information.
        if (params.has_key?(:client))

          render :template => "users/clientsearch"

        end
      }
    end
  end

  # GET /users
  # GET /users.json
  def index
    respond_to do |format|

        format.html {
            @users = User.paginate(page: params[:page],
                               per_page: params[:per_page])
                     .order('surname, firstname')
        }

        # CG - Add JSON formatter to list all users if accesing via web service, rather than using pagination.
        format.json {

            # CG - Get all the users from the model/DB.
             @users = User.all
        }
    end
  end

  # GET /users/1
  # GET /users/1.json
  # Can be called either by an admin to show any user account or else by
  # a specific user to show their own account, but no one else's

  # CG - Rails goes to views/users/show.html.erb

  def show
    if current_user.id == @user.id || is_admin?
      respond_to do |format|

        format.js { render partial: 'show_local',
                           locals: {user: @user, current_page: @current_page},
                           layout: false }
        format.html # show.html.erb
        format.json # show.json.builder
        format.xml  { render :xml => @user.to_xml }
      end
    else
      #indicate_illegal_request I18n.t('users.not-your-account')
      indicate_unauthorised_request I18n.t('users.not-your-account')
    end
  end

  # GET /users/new
  def new
    @user = User.new
    @user.user_detail = UserDetail.new
  end

  # GET /users/1/edit
  # Can be called either by an admin to edit any user account or else by
  # a specific user to edit their own account, but no one else's
  def edit
    if !(current_user.id == @user.id || is_admin?)
      indicate_illegal_request I18n.t('users.not-your-account')
    end
  end

  # POST /users
  # POST /users.json
  # At the moment we are only allowing the admin user to create new
  # accounts.

  # CG - Above line wasn't ACTUALLY correct, until I put the check in at the top of the file.
  def create

    # CG - Mass assign incoming form data to new object that will be stored in the database.
    @user = User.new(user_params)

    # Only create a new image if the :image_file parameter
    # was specified
    @image = Image.new(photo: params[:image_file]) if params[:image_file]

    # The ImageService model wraps up application logic to
    # handle saving images correctly
    @service = ImageService.new(@user, @image)

    respond_to do |format|
      if @service.save # Will attempt to save user and image
        format.html { redirect_to(user_url(@user, page: @current_page),
                                  notice: I18n.t('users.account-created')) }
        format.json { render action: 'show', status: :created, location: @user }
      else
        format.html { render action: 'new' }

        # CG - Changed from 422 to 400 Bad Request - Validation error.
        format.json { render json: {:errors => @user.errors.full_messages}, :status => :bad_request }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  # Can be called either by an admin to update any user account or else by
  # a specific user to update their own account, but no one else's
  def update
    if current_user.id == @user.id || is_admin?
      @image = @user.image
      @service = ImageService.new(@user, @image)

      respond_to do |format|
        if @service.update_attributes(user_params, params[:image_file])
          format.html { redirect_to(user_url(@user, page: @current_page),
                                    notice: I18n.t('users.account-created')) }

          # CG - Here we return only a header (no body) in the response, and as such respond with a HTTP 204 - No Content (success)
          format.json { head :no_content }

        else
          format.html { render action: 'edit' }
          format.json { render json: {:errors => @user.errors.full_messages}, :status => :unprocessable_entity }
        end
      end
    else
      indicate_illegal_request I18n.t('users.not-your-account')
    end
  end

# DELETE /users/1
# DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url(page: @current_page) }
      format.json { head :no_content }
    end
  end

  private
# Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  def set_current_page
    @current_page = params[:page] || 1
  end

  def search_fields(table)
    fields = []
    table.search_columns.each do |column|
      # The parameters have had the table name stripped off so we
      # have to to the same to each search_columns column
      fields << column if params[column.sub(/^.*\./, "")]
    end
    fields = nil unless fields.length > 0
    fields
  end

  def indicate_illegal_request(message)
    respond_to do |format|

      format.html {
        flash[:error] = message
        redirect_back_or_default(home_url)
      }
      format.json {
        render json: {:errors => ["#{message}"]}, :status => :unprocessable_entity
      }

    end
  end

    #CG - Add HTTP 401-Unauthorized response for invalid users.
    def indicate_unauthorised_request(message)
        respond_to do |format|
              format.html {
                flash[:error] = message
                redirect_back_or_default(home_url)
              }
              format.json {
                render json: {:errors => ["#{message}"]}, :status => :unauthorized
              }
        end
    end


  def show_record_not_found(exception)
    respond_to do |format|
      format.html {
        redirect_to(users_url(page: @current_page),
                    notice: I18n.t('users.account-no-exists'))
      }
      format.json {
        render json: {:errors => ["#{I18n.t('users.account-no-exists')}"]},

               # CG - Changed from 422 to 404 as we are not able to find the record.
               status: :not_found
      }
    end
  end

# Never trust parameters from the scary internet, only allow the white list through.

# CG - This private method is used to specify what data can be passed in from the 'params' hash-table.
# CG - '.require()' tells Rails that the 'params' hash-table MUST include a 'user' key. It must exist.

  def user_params
    params.require(:user).permit(:surname,
                                 :firstname,
                                 :phone,
                                 :grad_year,
                                 :jobs,
                                 :email,
                                 user_detail_attributes: [:id, :password, :password_confirmation, :login])
  end

end
