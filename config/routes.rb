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

  # Passwordless sign-in (D02) and two-factor challenge (F53)
  get  "users/magic_link",        to: "users/magic_links#new",  as: :users_magic_link
  post "users/magic_link",        to: "users/magic_links#create"
  get  "users/magic_link/:token", to: "users/magic_links#show", as: :users_magic_link_session
  get  "users/two_factor",        to: "users/two_factor#show",  as: :users_two_factor
  post "users/two_factor",        to: "users/two_factor#create"

  # Public city information
  resources :services, only: [ :index, :show ] do
    resource :review, only: [ :create ], controller: "service_reviews"
  end
  resources :partners, only: [ :index, :show ]
  resources :transports, only: [ :index ]
  resources :announcements, only: [ :index, :show ]
  resources :alerts, only: [ :index ]
  get "glossary", to: "glossary#index", as: :glossary
  get "status", to: "pages#status", as: :status

  # Participatory democracy (F65-F68). Ideas new/create and the nested
  # response/support actions require a citizen, enforced in the controllers.
  resources :projects, only: [ :index, :show ]
  resources :consultations, only: [ :show ] do
    resource :response, only: [ :create ], controller: "consultation_responses"
  end
  resources :ideas, only: [ :index, :show, :new, :create ] do
    resource :support, only: [ :create, :destroy ], controller: "idea_supports"
  end

  # Contact the municipal services (D04/F51) and trust pages
  resource :feedback, only: [ :new, :create ], controller: "feedbacks"
  get "transparency",  to: "pages#transparency",  as: :transparency
  get "accessibility", to: "pages#accessibility", as: :accessibility
  get "eco",           to: "pages#eco",           as: :eco

  # Citizen space
  authenticate :user do
    get "espace", to: "dashboard#show", as: :citizen_dashboard

    resources :requests, only: [ :index, :show, :new, :create ] do
      resource :support, only: [ :create, :destroy ], controller: "request_supports"
    end
    resources :appointments, only: [ :index, :show, :new, :create ] do
      member { patch :cancel }
    end
    resources :notifications, only: [ :index, :update ]

    resource :profile,    only: [ :show, :edit, :update ], controller: "profiles"
    resource :onboarding, only: [ :show, :update ],        controller: "onboarding"
    resource :account,    only: [ :show, :destroy ],       controller: "accounts" do
      get :data
      get :export
    end

    get    "profile/two_factor", to: "two_factor_settings#show",    as: :two_factor_settings
    post   "profile/two_factor", to: "two_factor_settings#create"
    delete "profile/two_factor", to: "two_factor_settings#destroy"
  end

  # Municipal agent workspace (distinct from the citizen space)
  authenticate :agent do
    namespace :agents do
      root "dashboard#index"

      # Demands streamed by the external Webcup API (D19)
      resources :demands, only: [ :index, :show, :update ] do
        collection { post :refresh }
      end

      # Citizen account administration (F34/F71)
      resources :users, only: [ :index, :show, :new, :create, :edit, :update ] do
        member { patch :unlock }
      end

      # Citizen requests / signalements (F22/D17/F75)
      resources :requests, only: [ :index, :show, :update ] do
        member do
          patch :link_duplicate
          patch :prioritize
        end
      end

      # Appointment scheduling (F39/F40)
      resources :appointments, only: [ :index, :show, :edit, :update ] do
        member { patch :cancel }
      end
      resources :availabilities, only: [ :index, :create, :destroy ]
      resources :time_offs, only: [ :create, :destroy ]

      # Announcements and urgent alerts (D18/F29/F30/F31)
      resources :announcements
      resources :alerts

      # Audit trail (F47/F48)
      resources :audit_logs, only: [ :index, :show ]

      # Citizen messages (D04/F51)
      resources :feedbacks, only: [ :index, :show, :update ]

      # Service catalog administration and quick disable (F63)
      resources :services, only: [ :index, :edit, :update ] do
        member do
          patch :disable
          patch :enable
        end
      end

      # Participatory democracy management (F65-F68)
      resources :projects
      resources :consultations
      resources :ideas, only: [ :index, :show, :update ]

      # Partners (F74), service reviews (F76) and security monitoring (F69/F70)
      resources :partners do
        member { patch :hours }
      end
      resources :service_reviews, only: [ :index, :update ]
      resources :security_events, only: [ :index ]
    end
  end
end
