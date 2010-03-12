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

require 'RMagick'

class AvatarsController < ApplicationController
  include Magick
  
  TMP_PATH = File.join(RAILS_ROOT, "public", "images", "tmp")
  
  def precrop
    if params['avatar']['media'].blank?
      redirect_to request.referer
      return
    end
    
    @user = User.find_by_login(params[:user_id])
    @avatar = @user.profile!.logo || Avatar.new 

    f = File.open(File.join(TMP_PATH,"precropavatar-#{@user.id}"), "w+")
    f.write(params['avatar']['media'].read)
    f.close
    @image = "tmp/" + File.basename(f.path)
    session[:tmp_avatar] = {}
    session[:tmp_avatar][:basename] = File.basename(f.path)
    session[:tmp_avatar][:original_filename] = params['avatar']['media'].original_filename
    session[:tmp_avatar][:content_type] = params['avatar']['media'].content_type


    resize_if_bigger f.path, 600 
    
    @logo_crop_text = t('avatar.crop')
    @form_for       = @avatar
    @form_url       = [@user, @avatar]
    
    render :template => "logos/precrop", :layout => false
  end
  
  def create
    user = User.find_by_login(params[:user_id])
    if params[:crop_size].present?
      crop_and_resize
    end
    @avatar = user.profile!.build_logo(params[:avatar])
    if @avatar.save
      flash[:success] = t('avatar.created')
      redirect_to user_profile_path(user)
    else
      flash[:error] = t('error', :count => @avatar.errors.size) + @avatar.errors.to_xml
      redirect_to user_profile_path(user)
    end
    
  end
  
  def update
     user = User.find_by_login(params[:user_id])
    if params[:crop_size].present?
      crop_and_resize
    end
    @avatar = user.profile
    if @avatar.logo.update_attributes(params[:avatar])
      flash[:success] = t('avatar.created')
      redirect_to user_profile_path(user)
    else
      flash[:error] = t('error', :count => @avatar.logo.errors.size) + @avatar.logo.errors.to_xml
      redirect_to user_profile_path(user)
    end   
  end
  
  private

  def crop_and_resize 
      
    img = Magick::Image.read(File.open(File.join(TMP_PATH,session[:tmp_avatar][:basename]))).first

    crop_args = %w( x y width height ).map{ |k| params[:crop_size][k] }.map(&:to_i)
    crop_img = img.crop(*crop_args)
    f = ActionController::UploadedTempfile.open("cropavatar","tmp")
    crop_img.write("png:" + f.path)
    f.instance_variable_set "@original_filename",session[:tmp_avatar][:original_filename]
    f.instance_variable_set "@content_type", session[:tmp_avatar][:content_type]
    params[:avatar] ||= {}
    params[:avatar][:media] = f

  end

  def resize_if_bigger path, size
    
    f = File.open(path)
    img = Magick::Image.read(f).first
    if img.columns > img.rows && img.columns > size
      resized = img.resize(size.to_f/img.columns.to_f)
      f.close
      resized.write("png:" + path)
    elsif img.rows > img.columns && img.rows > size
      resized = img.resize(size.to_f/img.rows.to_f)
      f.close
      resized.write("png:" + path)
    end
    
  end
  
end
