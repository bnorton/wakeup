class ApplicationController < ActionController::Base
  protect_from_forgery :with => :null_session
  before_filter :authenticate!

  private

  rescue_from ActiveRecord::RecordNotUnique do |ex|
    Rails.logger.error "#{relation} raised RecordNotUnique with #{ex.message}"
    notfound
  end

  rescue_from ActiveRecord::RecordNotSaved do |ex|
    Rails.logger.error "#{relation} raised RecordNotSaved with #{ex.message}"
    yourfault
  end

  def authenticate!
    notfound unless user.present?
  end

  def user_id; params[:user_id] || params[:id] end
  def user_token; request.headers[TOKEN] end

  def user
    @user ||= begin
      user = user_id.presence && User.find(user_id)
      user if (user.present? && user_token.present? && user.token == user_token)
    end
  end

  def json(item)
    status = :ok
    status = :created if create?

    render :json => "#{item.class}Presenter".constantize.new(item), :status => status
  end

  def notfound
    error :not_found
  end

  def yourfault
    error :unprocessable_entity
  end

  def _create(*names)
    relation.create!(params.permit(*names))
  end

  def create?
    params[:action] == CREATE
  end

  def _update(*names)
    relation.update_attributes!(params.permit(*names)) && relation
  end

  def relation
    @relation ||= RELATION[params[:controller]][params[:action]].(self)
  end

  def error(type)
    render :json => {}, :status => type
  end
end

ApplicationController::TOKEN  = 'X-User-Token'.freeze
ApplicationController::CREATE = 'create'.freeze
ApplicationController::RELATION = {
  'users' => {
    'create' => proc { User },
    'update' => ->(c) { User.find(c.params[:id]) }
  }
}
