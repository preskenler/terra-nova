# Be sure to restart your server when you modify this file.

# Content Security Policy. See:
# https://guides.rubyonrails.org/security.html#content-security-policy-header
Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.font_src    :self, :https, :data
    # OpenStreetMap tiles for the Leaflet map picker.
    policy.img_src     :self, :https, :data, "https://*.tile.openstreetmap.org"
    policy.object_src  :none
    policy.script_src  :self
    policy.style_src   :self, :https
    # Leaflet sets inline positioning styles at runtime; CSS attributes are
    # governed by style-src-attr (narrower than style-src).
    policy.style_src_attr :unsafe_inline
    policy.connect_src :self
    policy.frame_ancestors :none
    policy.base_uri    :self
    policy.form_action :self
  end

  # Generate session nonces for permitted importmap and inline scripts.
  config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
  config.content_security_policy_nonce_directives = %w[script-src]

  # Automatically add `nonce` to javascript_tag / javascript_include_tag helpers
  # (including importmap tags) for the configured directives.
  config.content_security_policy_nonce_auto = true
end
