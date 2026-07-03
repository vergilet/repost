require 'spec_helper'

RSpec.describe Repost::Senpai do
  let(:url) { 'http://example.com/endpoint' }
  let(:html) { described_class.perform(url) }

  it 'generates post form' do
    aggregate_failures do
      expect(html).to include('form')
      expect(html).to include(url)
      expect(html).to include("type=\"submit\"")
    end
  end

  it 'autosubmit form by default' do
    expect(html).to include('.submit()')
  end

  describe 'with params' do
    let(:params) do
      {
        name: 'TestName',
        description: 'Some cool description',
        count: 696,
        string_size: '234',
        boolean: true,
        string_boolean: 'false',
        quoted_string: "Tuan O'Keefe",
        double_quoted_string: "Sam O\"Daren"
      }
    end

    let(:html) { described_class.perform(url, params: params) }

    it 'generates post form' do
      aggregate_failures do
        expect(html).to include("input type=\"hidden\"")
        expect(html).to include("value=\"#{params[:name]}\"")
        expect(html).to include("value=\"#{params[:description]}\"")
        expect(html).to include("value=\"#{params[:string_size]}\"")
        expect(html).to include("value=\"#{params[:string_boolean]}\"")
        expect(html).to include("value=\"Tuan O&#39;Keefe\"")
        expect(html).to include("value=\"Sam O&quot;Daren\"")
        expect(html).to include("value=\"#{params[:count]}\"")
        expect(html).to include("value=\"#{params[:boolean]}\"")
      end
    end

    describe 'with unsafe values' do
      let(:params) do
        {
          xss: %q("><script>alert(1)</script>)
        }
      end

      it 'escapes html in attribute values' do
        aggregate_failures do
          expect(html).to_not include('<script>alert(1)</script>')
          expect(html).to include('value="&quot;&gt;&lt;script&gt;alert(1)&lt;/script&gt;"')
        end
      end
    end

    describe 'with nested params' do
      let(:params) do
        {
          top_level: {
            top_level_item: "hello",
            second_level: {
              third_level: "qwerty",
              array: [1, 2, "3", {a: 4, b: "5"}]
            },
          },
        }
      end

      it 'handles arbitrarily nested params' do
        aggregate_failures do
          expect(html).to include("name=\"top_level[top_level_item]\" value=\"hello\"")
          expect(html).to include("name=\"top_level[second_level][third_level]\" value=\"qwerty\"")
          expect(html).to include("name=\"top_level[second_level][array][]\" value=\"1\"")
          expect(html).to include("name=\"top_level[second_level][array][]\" value=\"2\"")
          expect(html).to include("name=\"top_level[second_level][array][]\" value=\"3\"")
          expect(html).to include("name=\"top_level[second_level][array][][a]\" value=\"4\"")
          expect(html).to include("name=\"top_level[second_level][array][][b]\" value=\"5\"")
        end
      end
    end

    describe 'with array params' do
      let(:params) do
        {
          multi_item: ["hello"],
          second_level: {
            multi_item: ["qwerty"]
          }
        }
      end

      it 'handles enumerable params' do
        aggregate_failures do
          expect(html).to include("name=\"multi_item[]\" value=\"hello\"")
          expect(html).to include("name=\"second_level[multi_item][]\" value=\"qwerty\"")
        end
      end
    end
  end

  describe 'with options' do
    let(:options) { {} }
    let(:html) { described_class.perform(url, options: options) }

    context 'empty options' do
      it 'autosubmit form by default' do
        expect(html).to include('.submit()')
      end
    end

    context 'set options' do
      describe 'autosubmit' do
        context 'enabled' do
          let(:options) do
            {
              autosubmit: true
            }
          end

          it 'returns submit function' do
            aggregate_failures do
              expect(html).to include('.submit()')
              expect(html).to include('<noscript>')
            end
          end
        end

        context 'disabled' do
          let(:options) do
            {
              autosubmit: false
            }
          end

          it "doesn't return submit function" do
            aggregate_failures do
              expect(html).to_not include('.submit()')
              expect(html).to_not include('<noscript>')
            end
          end
        end
      end

      describe 'autosubmit_nonce' do
        context 'enabled' do
          let(:options) do
            {
              autosubmit_nonce: 'anonce',
            }
          end

          it 'includes nonce as script attr' do
            expect(html).to include '<script nonce="anonce">'
          end
        end

        context 'nil' do
          let(:options) do
            {}
          end

          it 'is bare script tag' do
            expect(html).to include '<script>'
          end
        end
      end

      describe 'method' do
        context 'default' do
          it 'submits via post without override' do
            aggregate_failures do
              expect(html).to include('method="post"')
              expect(html).to_not include('name="_method"')
            end
          end
        end

        context 'get' do
          let(:options) { { method: :get } }

          it 'submits via get without override' do
            aggregate_failures do
              expect(html).to include('method="get"')
              expect(html).to_not include('name="_method"')
            end
          end
        end

        context 'patch' do
          let(:options) { { method: :patch } }

          it 'submits via post with a _method override field' do
            aggregate_failures do
              expect(html).to include('method="post"')
              expect(html).to include('<input type="hidden" name="_method" value="patch">')
            end
          end
        end
      end

      describe 'decor' do
        let(:options) do
          {
            autosubmit: false,
            decor: {
              section: {
                classes: 'red-bg red-text',
                html: '<h1>Press this button!</h1>'
              },
              submit: {
                classes: 'button-decorated',
                text: 'Pay now'
              }
            }
          }
        end

        it 'decorates the confirmation section' do
          aggregate_failures do
            expect(html).to include('<div class="red-bg red-text">')
            expect(html).to include('<h1>Press this button!</h1>')
            expect(html).to include('<input class="button-decorated" type="submit" value="Pay now">')
          end
        end

        context 'without decor' do
          let(:options) { { autosubmit: false } }

          it 'omits class attributes' do
            aggregate_failures do
              expect(html).to_not include('class=""')
              expect(html).to include('<input type="submit" value="Continue">')
            end
          end
        end
      end
    end
  end
end
