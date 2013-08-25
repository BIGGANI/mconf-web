# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.


class AttachmentsController < ApplicationController
  include ActionController::StationResources

  before_filter :space!
  before_filter :webconf_room!
  before_filter :except => [ :new, :edit ]
  load_and_authorize_resource :space, :find_by => :permalink
  load_and_authorize_resource :attachment, :through => :space

  layout 'spaces_show'

  def index
    # gon usage for making @space and other variables available to js
    gon.clear
    gon.space = @space
    # TODO see better way to use paths with gon
    gon.attachments_path = space_attachments_path(@space)
    gon.form_auth_token = form_authenticity_token()
    attachments
    respond_to do |format|
      format.html
      format.zip{
        generate_and_send_zip
      }
    end
  end

  def edit_tags
    @attachment = Attachment.find(params[:id])
    respond_to do |format|
      format.html {
        render :partial => "edit_tags_form"
      }
    end
  end

  def new
    respond_to do |format|
      format.html {
        render :partial => "upload_form"
      }
    end
  end

  def edit
    respond_to do |format|
      format.html {
        render :partial => "edit"
      }
    end
  end

  def delete_collection
    if params[:attachment_ids].blank?
      flash[:error] = "Malformed request"
      redirect_to space_attachments_path(@space)
    else
      attachments
      errors = ""
      @attachments.each do |attachment|
        if can?(:destroy, attachment)
          attachment.tags.each do |tag|
            tag.delete
          end
          unless attachment.delete
            errors += I18n.t("attachment.error.not_deleted", :file => attachment.filename)
          end
        else
          errors += I18n.t("attachment.error.not_permission", :file => attachment.filename, :user => current_user.username)
        end
      end
      if errors==""
        flash[:success] = I18n.t("attachment.deleted")
      else
        flash[:error] = errors
      end

      redirect_to space_attachments_path(@space)
    end
  end

  private

  def attachments
    @attachments,@tags = Attachment.repository_attachments(@space, params)
  end

  # Redirect to spaces/:permalink/attachments if new attachment is created
  def after_create_with_success
    redirect_to [ space, Attachment.new ]
  end

  def after_update_with_success
    redirect_to [ space, Attachment.new ]
  end

  def after_create_with_errors
    flash[:error] =  @attachment.errors.to_xml
    attachments
    render :action => :index
    flash.delete([:error])
  end

  def after_update_with_errors
    flash[:error] = @attachment.errors.to_xml
    attachments
    render :action => :index
    flash.delete([:error])
  end

  def generate_and_send_zip
    require 'zip/zip'
    require 'zip/zipfilesystem'

    t = Tempfile.new("#{@attachments.size}files-#{Time.now.to_f}.zip")

    Zip::ZipOutputStream.open(t.path) do |zos|
      @attachments.each do |file|
        zos.put_next_entry(file.filename)
        zos.print IO.read(file.full_filename)
      end
    end

    send_file t.path, :type => 'application/zip', :disposition => 'attachment', :filename => "#{@attachments.size} files from #{@space.name}.zip"

    t.close
  end

end
