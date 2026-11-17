# Be sure to restart your server when you modify this file.

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.font_src    :self, :https, :data
    policy.img_src     :self, :https, :data
    policy.object_src  :none
    policy.script_src  :self # add specific hosts here if you load third-party scripts
    policy.style_src   :self, :https, :unsafe_inline # Tailwind requires inline styles
    policy.connect_src :self, :https
  end

  # Nonce for importmap/inline scripts (avoids unsafe-inline on script-src).
  # Stable per session, not per request: the importmap tag is Turbo-tracked, so a nonce that changes
  # on every response would force a full reload on each navigation. Stored in the session instead of
  # using `request.session.id`, which is blank on a visitor's first request (empty nonce = scripts blocked)
  # and changes when Devise rotates the session id on sign-in.
  config.content_security_policy_nonce_generator = ->(request) { request.session[:csp_nonce] ||= SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w[script-src]
end
