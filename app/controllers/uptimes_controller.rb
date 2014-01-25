class UptimesController < ApplicationController
  def create
    json _create(:user_id, :offset)
  end

  def update
    json _update(:offset)
  end
end
