Rails.application.routes.draw do
  root "home#index"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  # Interface language and accessibility preferences (session + profile).
  patch "locale",      to: "locales#update",     as: :locale
  patch "preferences", to: "preferences#update", as: :preferences

  # Authentication
  devise_for :users
  devise_for :agents, path: "agents", controllers: { sessions: "agents/sessions" }

  # Municipal agent workspace (distinct from the citizen space)
  authenticate :agent do
    namespace :agents do
      root "dashboard#index"

      # Demands streamed by the external Webcup API (D19)
      resources :demands, only: [ :index, :show, :update ] do
        collection { post :refresh }
      end
    end
  end
end
