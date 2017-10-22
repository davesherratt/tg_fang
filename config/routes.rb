Rails.application.routes.draw do
        root :to => "receives#index"
        post '/email_processor' => 'receives#create', as: :email_processor
end
