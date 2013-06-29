# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class SpacesController < ApplicationController
  include ActionController::StationResources

  before_filter :space
  before_filter :webconf_room!, :only => [:show, :edit]
  before_filter :authenticate_user!, :only => [:new, :create]

  load_and_authorize_resource

  # TODO: cleanup the other actions adding respond_to blocks here
  respond_to :js, :only => [:index, :show]
  respond_to :html, :only => [:new, :edit, :index, :show]

  # User trying to access a space not owned or joined by him
  rescue_from CanCan::AccessDenied do |exception|
    if user_signed_in? and not [:destroy, :update].include?(exception.action)
      # Normal actions trigger a redirect to ask for membership
      flash[:error] = t("join_request.message_title")
      redirect_to new_space_join_request_path :space_id => params[:id]
    else
      # Logged out users or destructive actions are redirect to the 403 error
      flash[:error] = t("space.access_forbidden")
      render :template => "/errors/error_403", :status => 403, :layout => "error"
    end
  end

  def index
    #if params[:space_id] && params[:space_id] != "all" && params[:space_id] !="my" && params[:space_id] !=""
    #  redirect_to space_path(Space.find_by_permalink(params[:space_id]))
    #  return
    #end
    if params[:view].nil? or params[:view] != "thumbnails"
      params[:view] = "list"
    end
    @spaces = Space.order('name ASC').all
    @private_spaces = @spaces.select{|s| !s.public?}
    @public_spaces = @spaces.select{|s| s.public?}

    if user_signed_in? && current_user.spaces.any?
      @user_spaces = current_user.spaces
    else
      @user_spaces = []
    end

    if @space
       session[:current_tab] = "Spaces"
    end
    if params[:manage]
      session[:current_tab] = "Manage"
      session[:current_sub_tab] = "Spaces"
    end

    respond_with @spaces do |format|
      format.html { render :index }
      format.js {
        json = @spaces.to_json(space_to_json_hash)
        render :json => json, :callback => params[:callback]
      }
      format.xml { render :xml => @public_spaces }
    end
  end

  def show
    @news_position = (params[:news_position] ? params[:news_position].to_i : 0)
    @news = @space.news.order("updated_at DESC").all
    @news_to_show = @news[@news_position]
    @posts = @space.posts
    @lastest_posts = @posts.not_events().where(:parent_id => nil).where('author_id is not null').order("updated_at DESC").first(3)
    @lastest_users = @space.stage_permissions.sort {|x,y| y.created_at <=> x.created_at }.first(3).map{ |p| p.user }
    @lastest_users.reject!{ |u| u.nil? }
    @upcoming_events = @space.events.order("start_date ASC").all.select{ |e| e.start_date && e.start_date.future? }.first(5)
    @permission = Permission.where(:user_id => current_user, :subject_id => @space, :subject_type => 'Space').first
    @current_events = (Event.in(@space).all :order => "start_date ASC").select{|e| e.start_date && !e.start_date.future? && e.end_date.future?}
    respond_to do |format|
      format.html { render :layout => 'spaces_show' }
      format.js {
        json = @space.to_json(space_to_json_hash)
        render :json => json, :callback => params[:callback]
      }
    end
  end

  def new
    @space = Space.new
    @space.build_bigbluebutton_room
    respond_with @space do |format|
      format.html { render :layout => 'no_sidebar' }
    end
  end

  def edit
    # @users = @space.actors.sort {|x,y| x.name <=> y.name }
    @permissions = space.stage_permissions.sort{
      |x,y| x.user.name <=> y.user.name
    }
    @roles = Space.roles
    render :layout => 'spaces_show'
  end

  def create
    # TODO: this shouldn't be here, can be in the model
    params[:space][:repository] = 1;

    @space = Space.new(params[:space])

    if @space.save
      respond_with @space do |format|
        flash[:success] = t('space.created')
        @space.stage_permissions.create(:user => current_user, :role => Space.role('Admin'))
        format.html { redirect_to :action => "show", :id => @space  }
      end
    else
      respond_with @space do |format|
        format.html { render :action => :new, :layout => "no_sidebar" }
      end
    end
  end

  def update
    # TODO update bigbluebutton_room.private when room.public is updated
    #unless params[:space][:public].blank?
    #  params[:space][:bigbluebutton_room_attributes] = Hash.new if params[:space][:bigbluebutton_room_attributes].blank?
    #  params[:space][:bigbluebutton_room_attributes][:private] = params[:space][:public] == "true" ? "false" : "true"
    #end

    unless params[:space][:bigbluebutton_room_attributes].blank?
      params[:space][:bigbluebutton_room_attributes][:id] = @space.bigbluebutton_room.id
    end

    if @space.update_attributes(params[:space])
      respond_to do |format|
        format.html {
          flash[:success] = t('space.updated')
          redirect_to request.referer
        }
        format.js {
          if params[:space][:name] or params[:space][:description]
            @result = params[:space][:name] ? nil : params[:space][:description]
            flash[:success] = t('space.updated')
            render "result", :formats => [:js]
          elsif !params[:space][:bigbluebutton_room_attributes].blank?
            if params[:space][:bigbluebutton_room_attributes][:moderator_password] or params[:space][:bigbluebutton_room_attributes][:attendee_password]
              @result = params[:space][:bigbluebutton_room_attributes][:moderator_password] ? params[:space][:bigbluebutton_room_attributes][:moderator_password] : params[:space][:bigbluebutton_room_attributes][:attendee_password]
              flash[:success] = t('space.updated')
              render "result", :formats => [:js]
            end
          else
            render "update", :formats => [:js]
          end
        }
      end
    else
      respond_to do |format|
        flash[:error] = t('error.change')
        format.js {
          @result = "$(\"#admin_tabs\").before(\"<div class=\\\"error\\\">" + t('.error.not_valid') +  "</div>\")"
        }
        format.html { redirect_to edit_space_path }
      end
    end
  end

  def destroy
    @space_destroy = Space.find_with_param(params[:id])
    @space_destroy.disable
    respond_to do |format|
      format.html {
        if request.referer.present? && request.referer.include?("manage") && current_user.superuser?
          flash[:notice] = t('space.disabled')
          redirect_to manage_spaces_path
        else
          flash[:notice] = t('space.deleted')
          redirect_to(spaces_url)
        end
      }
    end
  end

  def enable
    unless @space.disabled?
      flash[:notice] = t('space.error.enabled', :name => @space.name)
      redirect_to request.referer
      return
    end

    @space.enable

    flash[:success] = t('space.enabled')
    respond_to do |format|
      format.html { redirect_to manage_spaces_path }
    end
  end

  def leave
    permission = @space.stage_permissions.find_by_user_id(current_user)
    if permission
      permission.destroy
      respond_to do |format|
        format.html {
          flash[:success] = t('space.leave.success', :space_name => @space.name)
          if can?(:read, @space)
            redirect_to space_path(@space)
          else
            redirect_to root_path
          end
        }
      end
    else
      respond_to do |format|
        format.html { redirect_to space_path(@space) }
      end
    end
  end

  private

  def space
    if params[:action] == "enable"
      @space ||= Space.find_with_disabled_and_param(params[:id])
    else
      @space ||= Space.find_with_param(params[:id])
    end
  end

  def space_to_json_hash
    { :methods => :user_count, :include => {:logo => { :only => [:height, :width], :methods => :logo_image_path } } }
  end
end
