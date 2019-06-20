if defined?(Rails)
  class ::ActionController::Base

    def repost(*args)
      render html: Repost::Senpai.perform(*args).html_safe
    end

    alias :redirect_post :repost
  end
end
