require 'spec_helper'

describe ApplicationController do
  let(:options) { {} }

  Wakeup::Application.routes.draw do
    get 'users/:user_id/anonymous/new' => 'anonymous#new'
  end

  controller do
    def new
      head :ok
    end
  end

  after do
    Rails.application.reload_routes!
  end

  def response
    get :new, options

    super
  end

  it 'should be a 404' do
    response.code.should == '404'
  end

  describe 'when there is a user authenticate' do
    let(:user) { $user }

    before do
      options[:user_id] = user.id
    end

    it 'should be a 200' do
      response.code.should == '200'
    end
  end
end
