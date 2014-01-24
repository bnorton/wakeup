class UsersController < ApplicationController
  skip_before_filter :authenticate!, :only => [:create]

  def create
    json _create(:phone, :udid, :timezone, :locale, :version, :bundle)
  end

  def update
    json _update(:vcode, :timezone, :locale, :version)
  end
end
