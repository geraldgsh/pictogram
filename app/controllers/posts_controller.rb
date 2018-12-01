class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy, :like, :unlike]
  before_action :authenticate_user!
  before_action :current_user, only: [:edit, :update, :destroy]
  # Index action to render all posts
  def index
  following_ids = current_user.following.map(&:id)
  following_ids << current_user.id  
   @posts = Post.where(user_id: following_ids).order('created_at DESC').page params[:page]
    respond_to do |format|
      format.js
      format.html
    end
  end  
  
  def browse
    @posts = Post.all.order('created_at DESC').page params[:page]
    
    respond_to do |format|
      format.js
      format.html
    end
  end

  def show
  end

  # New action for creating post
  def new
    @post = current_user.posts.build
  end

  # Create action saves the post into database
  def create
    @post = current_user.posts.build(post_params)

    if @post.save
      flash[:success] = "Your post have successfully been created"
      redirect_to root_path
    else
      flash.now[:alert] = "Your new post couldn't be uploaded! Please check with system administrator"
      render :new
    end
  end

  def edit
  end

  def update
    if @post.update(post_params)
      flash[:success] = "Post updated"
      redirect_to posts_path
    else
      flash.now[:alert] = "Update failed. Please check form"
      render :edit
    end
  end

  def destroy
    @post.destroy
    flash[:success] = "Post deleted"
    redirect_to posts_path
  end

  def like
    if @post.liked_by current_user
      create_notification @post
      respond_to do |format|
        format.html { redirect_to :back }
        format.js
      end
    end
  end

  def unlike
    if @post.unliked_by current_user
      respond_to do |format|
        format.js
        format.html { redirect_to :back }
      end
    end
  end

  private
  def post_params
  	params.require(:post).permit(:image, :caption)
  end

  def set_post
    @post = Post.find(params[:id])
  end

    def owned_post
    unless current_user == @post.current_user
      flash[:alert] = "That post doesn't belong to you!"
      redirect_to root_path
    end
  end
  
  def create_notification(post)
    return if post.user == current_user
    Notification.create(user_id: post.user.id,
                        notified_by_id: current_user.id,
                        post_id: post.id,
                        identifier: post.id,
                        notice_type: 'like')
  end
end
