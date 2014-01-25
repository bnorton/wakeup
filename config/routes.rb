Wakeup::Application.routes.draw do
  resources :users, :only => [:create, :update] do
    resource :uptimes, :only => [:create, :update]
  end
end
