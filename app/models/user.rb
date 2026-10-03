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
  has_many :requests, dependent: :destroy
  has_many :request_supports, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :appointments, dependent: :destroy
  has_many :feedbacks, dependent: :nullify
  has_many :login_activities, dependent: :destroy
  has_many :consultation_responses, dependent: :destroy
  has_many :ideas, dependent: :destroy
  has_many :idea_supports, dependent: :destroy

  after_create :create_default_profile

  # Human-friendly label used in navigation and audit logs.
  def display_name
    email
  end

  # --- Two-factor authentication (F53) -------------------------------------

  def otp_enabled?
    otp_required? && otp_secret.present?
  end

  # Generates a TOTP secret the first time it is needed.
  def generate_otp_secret!
    update!(otp_secret: ROTP::Base32.random, otp_confirmed_at: nil) if otp_secret.blank?
    otp_secret
  end

  def otp_provisioning_uri
    ROTP::TOTP.new(otp_secret, issuer: "Nova Terra").provisioning_uri(email)
  end

  def verify_otp(code)
    return false if otp_secret.blank? || code.blank?

    ROTP::TOTP.new(otp_secret).verify(code.to_s.delete(" "), drift_behind: 30, drift_ahead: 30).present?
  end

  def enable_two_factor!
    update!(otp_required: true, otp_confirmed_at: Time.current)
  end

  def disable_two_factor!
    update!(otp_required: false, otp_secret: nil, otp_confirmed_at: nil)
  end

  private

  def create_default_profile
    create_profile unless profile
  end
end
