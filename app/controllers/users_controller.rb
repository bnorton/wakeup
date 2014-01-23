class UsersController < ApplicationController
  def create
    json _create(:phone, :udid, :timezone, :locale, :version, :bundle)
  end
end
