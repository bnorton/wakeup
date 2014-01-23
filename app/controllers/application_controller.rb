class ApplicationController < ActionController::Base
  protect_from_forgery :with => :null_session

  private

  rescue_from ActiveRecord::RecordNotUnique do |ex|
    Rails.logger.error "#{relation} raised RecordNotUnique with #{ex.message}"

    json_yourfault
  end

  def json(item)
    status = :ok
    status = :created if create?

    render :json => "#{item.class}Presenter".constantize.new(item), :status => status
  end

  def json_yourfault
    render :json => {}, :status => :unprocessable_entity
  end

  def _create(*names)
    relation.create(params.permit(*names))
  end

  def create?
    params[:action] == CREATE
  end

  def relation
    @relation ||= RELATION[params[:controller]][params[:action]]
  end
end

ApplicationController::CREATE = 'create'.freeze
ApplicationController::RELATION = {
  'users' => {
    'create' => User
  }
}
