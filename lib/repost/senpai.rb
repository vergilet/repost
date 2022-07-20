module Repost
  class Senpai < Action
    DEFAULT_SUBMIT_BUTTON_TEXT = 'Continue'
    DEFAULT_CHARSET = 'UTF-8'

    def initialize(url, params: {}, options: {})
      @url                = url
      @params             = params
      @options            = options
      @method             = options.fetch(:method, :post)
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

    def form_head
      %Q(<form id="#{form_id}" action="#{url}" method="#{method}" accept-charset="#{charset}">)
    end

    def form_body
      inputs = params.map do |key, value|
        form_input(key, value)
      end
      inputs.unshift(csrf_token) if authenticity_token
      inputs.join
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
        %Q(<input type="hidden" name="#{key}" value=#{process_value(value)}>)
      end
    end

    def form_footer
      %Q(</form>)
    end

    def csrf_token
      %Q(<input name="authenticity_token" value="#{authenticity_token}" type="hidden">)
    end

    def no_script
      %Q(<noscript>
        #{submit_section}
      </noscript>)
    end

    def submit_section
      %Q(<div class="#{section_classes}">
        #{section_html}
        <input class="#{submit_classes}" type="submit" value="#{submit_text}"></input>
      </div>)
    end

    def generated_form_id
      "repost-#{Time.now.to_i}"
    end

    def auto_submit_script
      nonce_attr = %Q( nonce="#{autosubmit_nonce}") if autosubmit_nonce
      %Q(<script#{nonce_attr}>
        document.getElementById("#{form_id}").submit();
      </script>)
    end

    def process_value(value)
      return value if value.is_a?(Integer)
      %Q("#{value.to_s.gsub("\"", '\'')}")
    end
  end
end
