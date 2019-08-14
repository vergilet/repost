if defined?(Rails)
  class ::ActionController::Base

    def repost(url, params: {}, options: {})
      render html: Repost::Senpai.perform(
        url,
        params: params,
        options: options.reverse_merge(authenticity_token: form_authenticity_token)
      ).html_safe
    end

    alias :redirect_post :repost

  end
end

# Sinatra & Rack Protection
# TODO
# defined?(Sinatra::Base) && defined?(Rack::Protection::AuthenticityToken)
# env&.fetch('rack.session', :csrf)
