# frozen_string_literal: true

module Users
  # Passwordless sign-in tokens (D02).
  #
  # A short-lived, single-use, signed token is emailed to the citizen. Consuming
  # it rotates a per-user nonce so the link cannot be replayed.
  class MagicLink
    PURPOSE = :magic_link
    TTL = 15.minutes

    class << self
      def verifier
        Rails.application.message_verifier(PURPOSE)
      end

      def generate(user)
        nonce = SecureRandom.hex(16)
        user.update_columns(magic_link_nonce: nonce, magic_link_sent_at: Time.current)
        verifier.generate(
          { "user_id" => user.id, "nonce" => nonce },
          expires_in: TTL, purpose: PURPOSE
        )
      end

      # @return [User, nil]
      def consume(token)
        payload = verifier.verified(token, purpose: PURPOSE)
        return nil if payload.blank?

        user = User.find_by(id: payload["user_id"])
        return nil if user.blank? || user.magic_link_nonce.blank?
        return nil unless ActiveSupport::SecurityUtils.secure_compare(
          user.magic_link_nonce, payload["nonce"].to_s
        )

        user.update_column(:magic_link_nonce, SecureRandom.hex(16)) # single use
        user
      end
    end
  end
end
