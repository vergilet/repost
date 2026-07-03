require 'cgi'
require 'securerandom'

module Repost
  class Senpai < Action
    DEFAULT_SUBMIT_BUTTON_TEXT = 'Continue'
    DEFAULT_CHARSET = 'UTF-8'
    # Browsers only submit forms via GET or POST; other verbs are sent as POST
    # with a Rails-style "_method" override field.
    OVERRIDE_METHODS = %w[put patch delete].freeze

    def initialize(url, params: {}, options: {})
      @url                = url
      @params             = params
      @options            = options
      @method             = options.fetch(:method, :post).to_s.downcase
      @authenticity_token = options.fetch(:authenticity_token, nil)
      @charset            = options.fetch(:charset, DEFAULT_CHARSET)
      @form_id            = options.fetch(:form_id, generated_form_id)
      @autosubmit         = options.fetch(:autosubmit, true)
      @autosubmit_nonce   = options.fetch(:autosubmit_nonce, nil)
      @section_classes    = options.dig(:decor, :section, :classes)
      @section_html       = options.dig(:decor, :section, :html)
      @submit_classes     = options.dig(:decor, :submit, :classes)
      @submit_text        = options.dig(:decor, :submit, :text) || DEFAULT_SUBMIT_BUTTON_TEXT
    end

    def perform
      compiled_body = if autosubmit
                        form_body << auto_submit_script << no_script
                      else
                        form_body << submit_section
                      end
      form_head << compiled_body << form_footer
    end

    private

    attr_reader :url, :params, :options, :method, :form_id, :autosubmit,
                :section_classes, :section_html, :submit_classes,
                :submit_text, :authenticity_token, :charset, :autosubmit_nonce

    def escape(value)
      CGI.escapeHTML(value.to_s)
    end

    def form_head
      %Q(<form id="#{escape(form_id)}" action="#{escape(url)}" method="#{escape(form_method)}" accept-charset="#{escape(charset)}">)
    end

    def form_method
      method_override? ? 'post' : method
    end

    def method_override?
      OVERRIDE_METHODS.include?(method)
    end

    def form_body
      inputs = params.map do |key, value|
        form_input(key, value)
      end
      inputs.unshift(csrf_token) if authenticity_token
      inputs.unshift(method_override_input) if method_override?
      inputs.join
    end

    def method_override_input
      %Q(<input type="hidden" name="_method" value="#{escape(method)}">)
    end

    def form_input(key, value)
      case value
      when Hash
        value.map do |inner_key, inner_value|
          form_input("#{key}[#{inner_key}]", inner_value)
        end.join
      when Array
        value.map do |inner_value|
          form_input("#{key}[]", inner_value)
        end.join
      else
        %Q(<input type="hidden" name="#{escape(key)}" value="#{escape(value)}">)
      end
    end

    def form_footer
      %Q(</form>)
    end

    def csrf_token
      %Q(<input name="authenticity_token" value="#{escape(authenticity_token)}" type="hidden">)
    end

    def no_script
      %Q(<noscript>#{submit_section}</noscript>)
    end

    def submit_section
      %Q(<div#{class_attr(section_classes)}>#{section_html}<input#{class_attr(submit_classes)} type="submit" value="#{escape(submit_text)}"></div>)
    end

    def class_attr(classes)
      %Q( class="#{escape(classes)}") if classes
    end

    def generated_form_id
      "repost-#{SecureRandom.hex(8)}"
    end

    def auto_submit_script
      nonce_attr = %Q( nonce="#{escape(autosubmit_nonce)}") if autosubmit_nonce
      %Q(<script#{nonce_attr}>
        document.getElementById("#{escape(form_id)}").submit();
      </script>)
    end
  end
end
