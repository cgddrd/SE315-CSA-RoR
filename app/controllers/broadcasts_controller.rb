class BroadcastsController < ApplicationController

  before_action :set_broadcast, only: [:show, :destroy]
  before_action :set_current_page, except: [:index]

  # This is an admin specific controller, so enforce access by admin only
  # This is a very simple form of authorisation
  before_action :admin_required

  rescue_from ActiveRecord::RecordNotFound, with: :show_record_not_found

  # Default number of entries per page
  PER_PAGE = 12

  # GET /broadcasts
  # GET /broadcasts.json
  def index

    # CG - Depending on the incoming format type (html, json or rss) render out the broadcasts accordingly. Uses one of three view templates: 'index.html.erb', 'index.json.builder' or 'index.rss.builder'

    # CG - If we wanted to, we could restrict to these three formats only, but Rails will choose the correct view template automatically based on the fincoming format type.
    respond_to do |format|

      format.html { @broadcasts = Broadcast.paginate(page: params[:page], per_page: params[:per_page]).order('created_at DESC') }

      # CG - If we are dealing with JSON/RSS responses, allow us to decide if we want to paginate the results, and if so, how mnay per page, and the current page.
      format.any(:json, :rss, :atom) {

        # CG - If we have specified 'per_page' URL parameter, then we should paginate results, otherwise return all results.
        if (!params.has_key?(:per_page)) || (!params[:per_page]) || params[:per_page] == "all"

          @broadcasts = Broadcast.all

        else

          @broadcasts = Broadcast.paginate(page: params[:page], per_page: params[:per_page]).order('created_at DESC')

        end

      }

    end

  end

  # GET /broadcasts/1
  # GET /broadcasts/1.json
  def show
  end

  # GET /broadcasts/new
  def new
    @broadcast = Broadcast.new
  end

  # POST /broadcasts
  # POST /broadcasts.json
  def create

    @broadcast = Broadcast.new(broadcast_params)

    # Wire up broadcast with the current user (an administrator)
    # Will be an admin user (see before_filter)
    # Note the current_user is a user_detail object so we need
    # to navigate to its user object
    @broadcast.user = current_user.user

    # Doing the next line forces a save automatically. I want to defer this
    # until the "if" statement
    #current_user.user.broadcasts << @broadcast

    no_errors = false

    respond_to do |format|

      if @broadcast.save

        # Only after saving do we try and do the real broadcast. Could have been
        # done using an observer, but I wanted this to be more explicit

        results = BroadcastService.broadcast(@broadcast, params[:feeds])


        if results.length > 0

          # Something went wrong when trying to broadcast to one or more of the
          # feeds.

          # CG - Old code.
          # @broadcast.errors[:base] << ("#{I18n.t('broadcasts.unable-message')}: #{results}")

          # CG - Extract all of the feed errors from the 'results' array so we can create a collection of 'error' JSON objects.
          results.each do |error|

            # CG - 'errors.add' is a Rails internal function to add a new error to the collection of all errors for the 'broadcast' object.
            @broadcast.errors.add(:feed_errors, error);

          end

          flash[:error] = I18n.t('broadcasts.saved-but-message')

        else
          flash[:notice] = I18n.t('broadcasts.saved-message')
          no_errors = true
        end
        if no_errors
          format.html { redirect_to(broadcasts_url(page: @current_page)) }
          format.json { render json: @broadcast, status: :created, location: @broadcast }
        else

          format.html { render :new }

          # CG - Fix this to return errors for JSON format rather than XML format. (ActionController::UnknownFormat)
          format.json {

            # Either say it partly worked but send back the errors or else send
            # back complete failure indicator (couldn't even save)
            if results

              # render json: @broadcast.errors, status: :created, location: @broadcast

              # CG - Update formatting of feed error messages so we can iterate through them in the client app.
              render json: {:errors => @broadcast.errors}, :status => :created

            else

              # render json: @broadcast.errors, status: :unprocessable_entity

              # CG - Update formatting of feed error messages so we can iterate through them in the client app.
              render json: {:errors => @broadcast.errors}, :status => :unprocessable_entity
            end
          }

        end
      end
    end
  end

  # DELETE /broadcasts/1
  # DELETE /broadcasts/1.json
  def destroy
    @broadcast.destroy
    respond_to do |format|
      format.html { redirect_to broadcasts_url }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_broadcast
    @broadcast = Broadcast.find(params[:id])
  end

  def set_current_page
    @current_page = params[:page] || 1
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def broadcast_params
    params.require(:broadcast).permit(:content)
  end

  # CG - Add ability to return HTML 404 code if broadcast cannot be found (e.g after deleting a broadcast)
  def show_record_not_found(exception)

      respond_to do |format|
        format.html {
          redirect_to(broadcasts_url)
        }
        format.json {
          render json: {:errors => ["#{I18n.t('broadcasts.broadcast-no-exists')}"]},

          status: :not_found
        }

    end
  end
end
