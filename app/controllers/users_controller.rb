class UsersController < ApplicationController
  def create
    json _create(:phone, :timezone, :locale, :version)
  end
end
