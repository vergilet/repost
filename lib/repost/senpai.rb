module Repost
  class Senpai < Action
    DEFAULT_SUBMIT_BUTTON_TEXT = 'Continue'

    def initialize(url, params: {}, options: {})
      @url             = url
      @params          = params
      @options         = options
      @method          = options[:method] || :post
      @form_id         = options[:form_id] || generated_form_id
      @autosubmit      = options.fetch(:autosubmit, true)
      @section_classes = options.dig(:decor, :section, :classes)
      @section_html    = options.dig(:decor, :section, :html)
      @submit_classes  = options.dig(:decor, :submit, :classes)
      @submit_text     = options.dig(:decor, :submit, :text) || DEFAULT_SUBMIT_BUTTON_TEXT
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
                :section_classes, :section_html, :submit_classes, :submit_text

    def form_body
      inputs = params.map do |key, value|
        "<input type='hidden' name='#{key}' value='#{value}'>"
      end
      inputs.join
    end

    def form_head
      "<form id='#{form_id}' action='#{url}' method='#{method}'>"
    end

    def form_footer
      "</form>"
    end

    def no_script
      "<noscript>
        #{submit_section}
      </noscript>"
    end

    def submit_section
      "<div class='#{section_classes}'>
        #{section_html}
        <input class='#{submit_classes}' type='submit' value='#{submit_text}'></input>
      </div>"
    end

    def generated_form_id
      "repost-#{Time.now.to_i}"
    end

    def auto_submit_script
      "<script>
        document.getElementById('#{form_id}').submit();
      </script>"
    end
  end
end
