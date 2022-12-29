Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root 'reports#new'
  post '/report', to: 'reports#create'
  get '/budgets', to: 'reports#budgets'
  post '/budgets', to: 'reports#create_pdf'
end
