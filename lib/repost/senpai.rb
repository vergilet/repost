require 'json'
require 'securerandom'

module Repost
  # Builds an HTML form that submits itself, so a browser can be "redirected"
  # with a POST body. All markup comes from #tag, which escapes every
  # attribute value, so no call site can forget to escape.
  class Senpai < Action
    DEFAULT_SUBMIT_BUTTON_TEXT = 'Continue'
    DEFAULT_CHARSET = 'UTF-8'
    DEFAULT_ALLOWED_SCHEMES = %w[http https].freeze
    # Browsers only submit forms via GET or POST; other verbs are sent as POST
    # with a Rails-style "_method" override field.
    OVERRIDE_METHODS = %w[put patch delete].freeze
    HTML_ESCAPES = { '&' => '&amp;', '<' => '&lt;', '>' => '&gt;', '"' => '&quot;', "'" => '&#39;' }.freeze
    # Characters that must not appear raw in a JS string inside <script>.
    JS_UNSAFE = /[<>&\u{2028}\u{2029}]/.freeze

    def initialize(url, params: {}, options: {})
      @url                = url.to_s
      @params             = params || {}
      @http_method        = options.fetch(:method, :post).to_s.downcase
      @authenticity_token = options.fetch(:authenticity_token, nil)
      @charset            = options.fetch(:charset, DEFAULT_CHARSET)
      @form_id            = options.fetch(:form_id) { generated_form_id }
      @autosubmit         = options.fetch(:autosubmit, true)
      @autosubmit_nonce   = options.fetch(:autosubmit_nonce, nil)
      @allowed_schemes    = Array(options.fetch(:allowed_schemes, DEFAULT_ALLOWED_SCHEMES)).map { |s| s.to_s.downcase }
      @section_classes    = options.dig(:decor, :section, :classes)
      @section_html       = options.dig(:decor, :section, :html)
      @submit_classes     = options.dig(:decor, :submit, :classes)
      @submit_text        = options.dig(:decor, :submit, :text) || DEFAULT_SUBMIT_BUTTON_TEXT
      check_url_scheme!
    end

    def perform
      controls = autosubmit ? auto_submit_script + tag(:noscript, submit_section) : submit_section
      tag(:form, form_inputs + controls,
          id: form_id, action: url, method: form_method, 'accept-charset': charset)
    end

    private

    attr_reader :url, :params, :http_method, :form_id, :autosubmit, :allowed_schemes,
                :section_classes, :section_html, :submit_classes,
                :submit_text, :authenticity_token, :charset, :autosubmit_nonce

    # The only place markup is produced. Attribute values are always escaped
    # (nil drops the attribute); content is markup built by this class, or
    # decor section html, which is raw by design.
    def tag(name, content = nil, **attributes)
      attrs = attributes.compact.map { |key, value| %( #{key}="#{escape(value)}") }.join
      content.nil? ? "<#{name}#{attrs}>" : "<#{name}#{attrs}>#{content}</#{name}>"
    end

    def escape(value)
      value.to_s.gsub(/[&<>"']/, HTML_ESCAPES)
    end

    # Escaping can't make a javascript: or data: URL safe, so only http(s)
    # and relative URLs are allowed unless the caller allows more schemes.
    def check_url_scheme!
      # Browsers ignore leading whitespace/control characters and drop tabs
      # and newlines anywhere, so "java\nscript:" still runs as javascript:.
      normalized = url.gsub(/[\t\n\r]/, '').sub(/\A[\x00-\x20]+/, '')
      scheme = normalized[/\A([a-z][a-z0-9+.\-]*):/i, 1]
      return if scheme.nil? || allowed_schemes.include?(scheme.downcase)

      raise UnsafeUrlError,
            "repost refuses to submit a form to a #{scheme}: URL. Allowed schemes: " \
            "#{allowed_schemes.join(', ')} (change with options[:allowed_schemes])"
    end

    def form_method
      method_override? ? 'post' : http_method
    end

    def method_override?
      OVERRIDE_METHODS.include?(http_method)
    end

    def form_inputs
      inputs = []
      inputs << hidden_input('_method', http_method) if method_override?
      inputs << hidden_input('authenticity_token', authenticity_token) if authenticity_token
      params.each { |key, value| inputs << form_input(key, value) }
      inputs.join
    end

    def form_input(name, value)
      case value
      when Hash  then value.map { |key, inner| form_input("#{name}[#{key}]", inner) }.join
      when Array then value.map { |inner| form_input("#{name}[]", inner) }.join
      else hidden_input(name, value)
      end
    end

    def hidden_input(name, value)
      tag(:input, type: 'hidden', name: name, value: value.to_s)
    end

    def submit_section
      button = tag(:input, class: submit_classes, type: 'submit', value: submit_text)
      tag(:div, "#{section_html}#{button}", class: section_classes)
    end

    # Calls the prototype's submit() so a param named "submit" (which the
    # browser exposes as form.submit, shadowing the method) can't break it.
    def auto_submit_script
      tag(:script, "HTMLFormElement.prototype.submit.call(document.getElementById(#{js_string(form_id)}));",
          nonce: autosubmit_nonce)
    end

    # A JS string literal that is also safe inside an HTML <script> element.
    # HTML escaping is wrong here: entities are not decoded inside <script>.
    def js_string(value)
      JSON.generate(value.to_s).gsub(JS_UNSAFE) { |char| format('\u%04x', char.ord) }
    end

    def generated_form_id
      "repost-#{SecureRandom.hex(8)}"
    end
  end
end
