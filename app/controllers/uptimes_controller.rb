class UptimesController < ApplicationController
  def create
    json _create(:user_id, :wake_at)
  end

  def update
    json _update(:wake_at)
  end
end
