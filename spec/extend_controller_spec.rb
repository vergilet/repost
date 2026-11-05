require 'spec_helper'
require 'rack/mock'

class RepostTestController < ActionController::Base
  def create
    url, params, options = request.env.fetch('repost.args')
    redirect_post(url, params: params, options: options)
  end
end

RSpec.describe Repost::ExtendController do
  def call_controller(url = 'https://bank.example/3ds', params: {}, options: {}, env: {})
    rack_env = Rack::MockRequest.env_for('/repost')
    rack_env['rack.session'] = {}
    rack_env['repost.args'] = [url, params, options]
    rack_env.merge!(env)
    status, headers, body = RepostTestController.action(:create).call(rack_env)
    html = +''
    body.each { |part| html << part }
    body.close if body.respond_to?(:close)
    [status, headers.to_h.transform_keys(&:downcase), html]
  end

  it 'is included into ActionController::Base only' do
    aggregate_failures do
      expect(ActionController::Base.ancestors).to include(described_class)
      expect(ActionController::API.ancestors).not_to include(described_class)
    end
  end

  it 'does not expose the helpers as routable actions' do
    expect(RepostTestController.action_methods).to contain_exactly('create')
  end

  it 'renders an auto-submitting form as HTML' do
    status, headers, html = call_controller(params: { 'MD' => 'abc' })

    aggregate_failures do
      expect(status).to eq(200)
      expect(headers['content-type']).to start_with('text/html')
      expect(html).to start_with('<form ')
      expect(html).to include('action="https://bank.example/3ds"')
      expect(html).to include('<input type="hidden" name="MD" value="abc">')
      expect(html).to include('HTMLFormElement.prototype.submit.call(')
    end
  end

  it 'escapes untrusted values instead of rendering them as markup' do
    payload = %q("><script>alert(1)</script>)
    _, _, html = call_controller(params: { payload => payload })

    aggregate_failures do
      expect(html).not_to include('<script>alert(1)')
      expect(html).to include('name="&quot;&gt;&lt;script&gt;alert(1)&lt;/script&gt;"')
    end
  end

  it 'uses the :status option and does not modify the options passed in' do
    options = { status: :accepted }.freeze
    status, = call_controller(options: options)

    aggregate_failures do
      expect(status).to eq(202)
      expect(options).to eq(status: :accepted)
    end
  end

  it 'adds the Rails CSRF token with authenticity_token: :auto' do
    _, _, html = call_controller(options: { authenticity_token: :auto })
    token = html[/name="authenticity_token" value="([^"]*)"/, 1]

    aggregate_failures do
      expect(token).not_to be_nil
      expect(token).not_to be_empty
      expect(token).not_to eq('auto')
    end
  end

  describe 'CSP nonce' do
    let(:nonce_env) { { 'action_dispatch.content_security_policy_nonce_generator' => ->(_request) { 'req-nonce' } } }

    it "uses the request's nonce by default" do
      _, _, html = call_controller(env: nonce_env)
      expect(html).to include('<script nonce="req-nonce">')
    end

    it 'uses an explicit :autosubmit_nonce instead' do
      _, _, html = call_controller(options: { autosubmit_nonce: 'mine' }, env: nonce_env)
      expect(html).to include('<script nonce="mine">')
    end

    it 'omits the nonce when :autosubmit_nonce is nil' do
      _, _, html = call_controller(options: { autosubmit_nonce: nil }, env: nonce_env)
      expect(html).to include('<script>')
    end
  end

  it 'refuses javascript: URLs' do
    expect { call_controller('javascript:alert(1)') }.to raise_error(Repost::UnsafeUrlError)
  end
end
