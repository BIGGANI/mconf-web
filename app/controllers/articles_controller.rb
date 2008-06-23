class ArticlesController < ApplicationController
  # Include some methods and set some default filters. 
  # See documentation: CMS::Controller::Contents#included
  include CMS::Controller::Contents
  
  # Articles list may belong to a container
  # /articles
  # /:container_type/:container_id/articles
  before_filter :get_container, :only => [ :index,:search_articles  ]
  
  # Needs a Container when posting a new Article
  before_filter :needs_container, :only => [ :new, :create ]
  
  # Get Article in member actions
  before_filter :get_content, :except => [ :index, :new, :create, :search_articles ]
  #before_filter :is_public_space, :only=>[:index]
  before_filter :get_space, :only => [ :index, :new, :create ,:search_articles ]
  before_filter :get_cloud
  
  
  def search_articles
    @query = params[:query]    
    @results = Article.find_by_contents(@query)
    @pos = @container.container_posts    
    @posts = []   
    @results.collect { |result|
      post = CMS::Post.find_by_content_type_and_content_id("CMS::Text", result.id)
      if @pos.include?(post)
        @posts << post
      end
    }
    respond_to do |format|   
      format.html {render :template=>'/articles/search_articles'}
      format.js 
    end
  end
  def create
    # Fill params when POSTing raw data
    set_params_from_raw_post
    
    set_params_title_and_description(self.resource_class)
    
    # FIXME: we should look for an existing content instead of creating a new one
    # every time a Content is posted.
    # Idea: Should use SHA1 on one or some relevant Content field(s) 
    # and find_or_create_by_sha1
    @content = instance_variable_set "@#{controller_name.singularize}", self.resource_class.create(params[:content])
    
    @post = CMS::Post.new(params[:post].merge({ :agent => current_agent,
      :container => @container,
      :content => @content }))
    
    
    
    respond_to do |format| 
      format.html {
        if !@content.new_record? && @post.save
          
          tag = params[:tag][:add_tag]    
          @post.tag_with(tag)
          @post.category_ids = params[:category_ids]
          flash[:valid] = "#{ @content.class.to_s.humanize } created".t
          redirect_to post_url(@post)
        else
          @content.destroy unless @content.new_record?
          @collection_path = container_contents_url
          @title ||= "New #{ controller_name.singularize.humanize }".t
          render :template => "posts/new"
        end
      }
      
      format.atom {
        if !@content.new_record? && @post.save
          headers["Location"] = formatted_post_url(@post, :atom)
          headers["Content-type"] = 'application/atom+xml'
          render :partial => "posts/entry",
          :status => :created,
          :locals => { :post => @post,
            :content => @content },
          :layout => false
        else
          if @content.new_record?
            render :xml => @content.errors.to_xml, :status => :bad_request
          else
            @content.destroy unless @content.new_record?
            render :xml => @post.errors.to_xml, :status => :bad_request
          end
        end
      }
    end
  end
  
  
  protected
  def get_space
    @space = @container
  end
end
