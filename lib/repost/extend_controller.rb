if defined?(Rails) && defined?(ActiveSupport)
  ActiveSupport.on_load(:action_controller) do
    class ::ActionController::Base
      def repost(url, params: {}, options: {})
        status = options.delete(:status) || :ok
        authenticity_token = if ['auto', :auto].include?(options[:authenticity_token])
                               form_authenticity_token
                             else
                               options[:authenticity_token]
                             end

        html_payload = Repost::Senpai.perform(
          url,
          params: params,
          options: options.merge({
                                   authenticity_token: authenticity_token,
                                   autosubmit_nonce: content_security_policy_nonce
                                 }.compact)
        )

        render html: html_payload.html_safe, status: status
      end

      alias :redirect_post :repost
    end
  end
end

# Sinatra & Rack Protection
# TODO
# defined?(Sinatra::Base) && defined?(Rack::Protection::AuthenticityToken)
# env&.fetch('rack.session', :csrf)
