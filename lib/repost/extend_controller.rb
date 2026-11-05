module Repost
  # Adds #repost and #redirect_post to Rails controllers. Included into
  # ActionController::Base when it loads (not into ActionController::API).
  module ExtendController
    def repost(url, params: {}, options: {})
      options = options.dup
      status = options.delete(:status) || :ok
      if ['auto', :auto].include?(options[:authenticity_token])
        options[:authenticity_token] = form_authenticity_token
      end
      # Rails' per-request CSP nonce is the default; an explicitly passed
      # :autosubmit_nonce (even nil, to opt out) takes precedence.
      unless options.key?(:autosubmit_nonce)
        options[:autosubmit_nonce] = content_security_policy_nonce if respond_to?(:content_security_policy_nonce, true)
      end

      # html_safe is correct here: Senpai escapes every value it inserts
      # (except decor section html, which is raw by design).
      render html: Repost::Senpai.perform(url, params: params, options: options).html_safe, status: status
    end

    alias redirect_post repost
  end
end

if defined?(ActiveSupport) && ActiveSupport.respond_to?(:on_load)
  ActiveSupport.on_load(:action_controller_base) { include Repost::ExtendController }
end
