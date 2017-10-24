Rails.application.routes.draw do
    root to: 'site#index'
    post '/email_processor' => 'receives#create', as: :email_processor

    namespace :api do 
    	namespace :v1 do 
    		resources :planets, only: [:index, :update] 
    	end 
    end

end
