# -*- coding: utf-8 -*-
# Copyright 2008-2010 Universidad Politécnica de Madrid and Agora Systems S.A.
#
# This file is part of VCC (Virtual Conference Center).
#
# VCC is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# VCC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with VCC.  If not, see <http://www.gnu.org/licenses/>.

class SpacesController < ApplicationController
  include ActionController::StationResources

  before_filter :space

  authentication_filter :only => [:new, :create]
  authorization_filter :read,   :space, :only => [:show]
  authorization_filter :update, :space, :only => [:edit, :update]
  authorization_filter :delete, :space, :only => [:destroy, :enable]

  set_params_from_atom :space, :only => [ :create, :update ]

  # TODO: cleanup the other actions adding respond_to blocks here
  respond_to :js, :only => [:index, :show]
  respond_to :html, :only => [:new, :edit, :index, :show]

  def index
    #if params[:space_id] && params[:space_id] != "all" && params[:space_id] !="my" && params[:space_id] !=""
    #  redirect_to space_path(Space.find_by_permalink(params[:space_id]))
    #  return
    #end
    @spaces = Space.find(:all, :order => 'name ASC')
    @private_spaces = @spaces.select{|s| !s.public?}
    @public_spaces = @spaces.select{|s| s.public?}

    if logged_in? && current_user.spaces.any?
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
  end

  def show
    @bbb_room = BigbluebuttonRoom.where("owner_id = ? AND owner_type = ?", @space.id, @space.class.name).first
    begin
      @bbb_room.fetch_meeting_info
    rescue Exception
    end

    @news_position = (params[:news_position] ? params[:news_position].to_i : 0)
    @news = @space.news.order("updated_at DESC").all
    @news_to_show = @news[@news_position]
    @posts = @space.posts
    @lastest_posts=@posts.not_events().find(:all, :conditions => {"parent_id" => nil}, :order => "updated_at DESC").first(3)
    @lastest_posts.reject!{ |p| p.author.nil? }
    @lastest_users=@space.stage_performances.sort {|x,y| y.created_at <=> x.created_at }.first(3).map{|performance| performance.agent}
    @lastest_users.reject!{ |u| u.nil? }
    @upcoming_events=@space.events.find(:all, :order => "start_date ASC").select{|e| e.start_date && e.start_date.future?}.first(5)
    @performance=Performance.find(:all, :conditions => {:agent_id => current_user, :stage_id => @space, :stage_type => "Space"})
    @current_events = (Event.in(@space).all :order => "start_date ASC").select{|e| e.start_date && !e.start_date.future? && e.end_date.future?}
  end

  def new
    @space = Space.new
    @space.build_bigbluebutton_room
  end

  def edit
    # @users = @space.actors.sort {|x,y| x.name <=> y.name }
    @performances = space.stage_performances.sort {|x,y| x.agent.name <=> y.agent.name }
    @roles = Space.roles
  end

  def create
    unless logged_in?
      if params[:register]
        cookies.delete :auth_token
        @user = User.new(params[:user])
        unless @user.save_with_captcha
          message = ""
          @user.errors.full_messages.each {|msg| message += msg + "  <br/>"}
          flash[:error] = message
          render :action => :new, :layout => "frontpage"
          return
        end
      end

      self.current_agent = User.authenticate_with_login_and_password(params[:user][:email], params[:user][:password])
      unless logged_in?
          flash[:error] = t('error.credentials')
          render :action => :new, :layout => "frontpage"
          return
      end
    end

    params[:space][:repository] = 1;

    params[:space][:bigbluebutton_room_attributes] ||= {}
    params[:space][:bigbluebutton_room_attributes][:name] = params[:space][:name]
    params[:space][:bigbluebutton_room_attributes][:private] = !ActiveRecord::ConnectionAdapters::Column.value_to_boolean(params[:space][:public])
    params[:space][:bigbluebutton_room_attributes][:server] = BigbluebuttonServer.first # TODO temporary
    params[:space][:bigbluebutton_room_attributes][:logout_url] = "/feedback/webconf/"

    @space = Space.new(params[:space])

    respond_to do |format|

      if @space.save
        flash[:success] = t('space.created')
        @space.stage_performances.create(:agent => current_user, :role => Space.role('Admin'))

        format.html { redirect_to :action => "show", :id => @space  }
      else
        format.html {
          message = ""
          @space.errors.full_messages.each {|msg| message += msg + "  <br/>"}
          flash[:error] = message
          render :action => :new, :layout => "application"
        }
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
            render "result.js"
          elsif !params[:space][:bigbluebutton_room_attributes].blank?
            if params[:space][:bigbluebutton_room_attributes][:moderator_password] or params[:space][:bigbluebutton_room_attributes][:attendee_password]
              @result = params[:space][:bigbluebutton_room_attributes][:moderator_password] ? params[:space][:bigbluebutton_room_attributes][:moderator_password] : params[:space][:bigbluebutton_room_attributes][:attendee_password]
              flash[:success] = t('space.updated')
              render "result.js"
            end
          else
            render "update.js"
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

  private

  def space
    if params[:action] == "enable"
      @space ||= Space.find_with_disabled_and_param(params[:id])
    else
      @space ||= Space.find_with_param(params[:id])
    end
  end
end
