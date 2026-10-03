class Agent < ApplicationRecord
  has_paper_trail ignore: %i[
    sign_in_count current_sign_in_at last_sign_in_at current_sign_in_ip
    last_sign_in_ip failed_attempts locked_at unlock_token reset_password_token
    reset_password_sent_at remember_created_at encrypted_password updated_at
  ]

  devise :database_authenticatable, :recoverable, :rememberable,
         :validatable, :trackable, :lockable, :timeoutable

  enum :role, { agent: "agent", admin: "admin" }, default: :agent

  has_many :appointments, dependent: :restrict_with_error
  has_many :agent_availabilities, dependent: :destroy
  has_many :agent_time_offs, dependent: :destroy

  def display_name
    email
  end

  def admin?
    role == "admin"
  end
end
