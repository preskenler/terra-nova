Rails.application.routes.draw do
  root "home#index"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  # Interface language and accessibility preferences (session + profile).
  patch "locale",      to: "locales#update",     as: :locale
  patch "preferences", to: "preferences#update", as: :preferences

  # Authentication
  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations"
  }
  devise_for :agents, path: "agents", controllers: { sessions: "agents/sessions" }

  # Public city information
  resources :services, only: [ :index, :show ]
  resources :transports, only: [ :index ]
  get "glossary", to: "glossary#index", as: :glossary

  # Citizen space
  authenticate :user do
    get "espace", to: "dashboard#show", as: :citizen_dashboard

    resource :profile,    only: [ :show, :edit, :update ], controller: "profiles"
    resource :onboarding, only: [ :show, :update ],        controller: "onboarding"
    resource :account,    only: [ :show, :destroy ],       controller: "accounts"
  end

  # Municipal agent workspace (distinct from the citizen space)
  authenticate :agent do
    namespace :agents do
      root "dashboard#index"

      # Demands streamed by the external Webcup API (D19)
      resources :demands, only: [ :index, :show, :update ] do
        collection { post :refresh }
      end

      # Citizen account administration (F34)
      resources :users, only: [ :index, :show, :edit, :update ] do
        member { patch :unlock }
      end
    end
  end
end
