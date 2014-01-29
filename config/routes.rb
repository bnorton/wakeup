Wakeup::Application.routes.draw do
  resources :users, :only => [:create, :update] do
    resource :uptimes, :only => [:create, :update]
    resources :sessions, :only => [:create, :update]
  end

  resources :seeds, :only => [] do
    collection { get :check, :action => 'check' }
  end
end
