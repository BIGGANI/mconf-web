# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "uri"
require "net/http"

class ShibbolethController < ApplicationController

  respond_to :html
  layout false

  # Log in a user using his shibboleth information
  # The application should only reach this point after authenticating using Shibboleth
  # The authentication is currently made with the Apache module mod_shib
  def create
    unless current_site.shib_enabled?
      redirect_to login_path
      return
    end

    # stores any "Shib-" variable in the session
    shib_data = {}
    request.env.each do |key, value|
      shib_data[key] = value if key.to_s.downcase =~ /^shib-/
    end
    session[:shib_data] = shib_data

    # the fields that define the name and email are configurable in the Site model
    shib_name = request.env[current_site.shib_name_field] || request.env["Shib-inetOrgPerson-cn"]
    shib_email = request.env[current_site.shib_email_field] || request.env["Shib-inetOrgPerson-mail"]

    # uses the fed email to check if the user already has an account
    user = User.find_by_email(shib_email)

    # the user already has an account but it was not activated yet
    if user and !user.active?
      @user = user
      render "need_activation"
      return
    end

    # the fed user has no account yet
    # create one based on the info returned by shibboleth
    if user.nil?
      password = SecureRandom.hex(16)
      user = User.create!(:username => shib_name.clone, :email => shib_email,
                          :password => password, :password_confirmation => password)
      user.activate
      user.profile.update_attributes(:full_name => shib_name)
      flash[:notice] = t('shibboleth.create.account_created', :url => new_user_password_path)
    end

    # login and go to home
    sign_in user, :bypass => true
    redirect_to my_home_path
  end

  def info
    @data = session[:shib_data] if session.has_key?(:shib_data)
  end

end
