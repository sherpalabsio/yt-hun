Rails.application.routes.draw do
  devise_for :users
  namespace :movies do
    resources :suggestions, only: %i[index] do
      delete :destroy, on: :collection
    end
  end
end
