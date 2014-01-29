class SessionsController < ApplicationController
  def create
    json _create(:started_at)
  end

  def update
    json _update(:ended_at)
  end
end
