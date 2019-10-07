if defined?(Rails)
  class ::ActionController::Base
    AUTO_TOKEN_OPTIONS = ['auto', :auto].freeze

    def repost(url, params: {}, options: {})
      authenticity_token = form_authenticity_token if AUTO_TOKEN_OPTIONS.include?(options[:authenticity_token])
      render html: Repost::Senpai.perform(
        url,
        params: params,
        options: options.merge({authenticity_token: authenticity_token}.compact)
      ).html_safe
    end

    alias :redirect_post :repost

  end
end

# Sinatra & Rack Protection
# TODO
# defined?(Sinatra::Base) && defined?(Rack::Protection::AuthenticityToken)
# env&.fetch('rack.session', :csrf)
