class User < ApplicationRecord
  # Track meaningful profile changes but never noise from authentication.
  # Note: paper_trail is configured at the top-level so Devise sign-ins do not
  # flood the versions table.
  has_paper_trail ignore: %i[
    sign_in_count current_sign_in_at last_sign_in_at current_sign_in_ip
    last_sign_in_ip failed_attempts locked_at unlock_token reset_password_token
    reset_password_sent_at remember_created_at encrypted_password updated_at
  ]

  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
         :validatable, :trackable, :lockable, :timeoutable

  enum :role, { citizen: "citizen", admin: "admin" }, default: :citizen

  has_one :profile, dependent: :destroy

  after_create :create_default_profile

  # Human-friendly label used in navigation and audit logs.
  def display_name
    email
  end

  private

  def create_default_profile
    create_profile unless profile
  end
end
