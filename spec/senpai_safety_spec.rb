require 'spec_helper'

RSpec.describe Repost::Senpai do
  describe 'target URL scheme' do
    [
      'javascript:alert(1)',
      ' JaVaScRiPt:alert(1)',
      "java\nscript:alert(1)",
      "\tjavascript:alert(1)",
      'data:text/html,<script>alert(1)</script>',
      'vbscript:msgbox(1)'
    ].each do |url|
      it "refuses #{url.inspect}" do
        expect { described_class.perform(url) }.to raise_error(Repost::UnsafeUrlError, /Allowed schemes: http, https/)
      end
    end

    [
      'http://example.com/endpoint',
      'HTTPS://example.com/endpoint',
      '//cdn.example.com/endpoint',
      '/payments/callback',
      'callback?step=2',
      '?step=2',
      ''
    ].each do |url|
      it "allows #{url.inspect}" do
        expect { described_class.perform(url) }.not_to raise_error
      end
    end

    it 'allows extra schemes through :allowed_schemes' do
      html = described_class.perform('myapp://pay', options: { allowed_schemes: %w[https myapp] })
      expect(html).to include('action="myapp://pay"')
    end

    it 'accepts URI objects' do
      html = described_class.perform(URI('https://example.com/a?b=1&c=2'))
      expect(html).to include('action="https://example.com/a?b=1&amp;c=2"')
    end
  end

  describe 'escaping' do
    let(:payload) { %q('"><img src=x onerror=alert(1)>) }

    it 'escapes every option that ends up in an attribute' do
      html = described_class.perform(
        "https://example.com/#{payload}",
        params: { payload => { payload => [payload] } },
        options: {
          method: payload,
          authenticity_token: payload,
          charset: payload,
          form_id: payload,
          autosubmit_nonce: payload,
          decor: { section: { classes: payload }, submit: { classes: payload, text: payload } }
        }
      )

      expect(html).not_to include('<img')
    end

    it 'keeps the escaped id usable from the autosubmit script' do
      html = described_class.perform('https://example.com', options: { form_id: 'a&b' })

      aggregate_failures do
        expect(html).to include('id="a&amp;b"')
        expect(html).to include('getElementById("a\\u0026b")')
      end
    end
  end
end
