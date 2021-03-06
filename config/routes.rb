Rails.application.routes.draw do
    root to: 'site#index'
    post '/email_processor' => 'receives#create', as: :email_processor

    namespace :api do 
    	namespace :v1 do 
    		resources :planets do
    			get '/planets/:x/:y/:z', to: 'planets#p'
                get 'api/v1/planets', to: 'planets#index'
    		end
            resources :incoming do
                post 'api/v1/incoming', to: 'incoming#index'
                post '/incoming', to: 'incoming#index'
            end
    	end 
    end
    get 'api/v1/planets/:x/:y/:z', to: 'api/v1/planets#p'
    post 'api/v1/incoming', to: 'api/v1/incoming#index'
    get '*unmatched_route', to: 'site#index'

end
