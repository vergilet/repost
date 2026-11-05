require_relative "lib/repost/version"

Gem::Specification.new do |spec|
  spec.name          = "repost"
  spec.version       = Repost::VERSION
  spec.authors       = ["YaroslavO"]
  spec.email         = ["osyaroslav@gmail.com"]

  spec.summary       = %q{Gem implements Redirect using POST method}
  spec.description   = %q{Helps to make POST 'redirect', but actually builds [form] with method: :post under the hood}
  spec.homepage      = "https://github.com/vergilet/repost"
  spec.license       = "MIT"

  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"]   = "#{spec.homepage}/blob/master/CHANGELOG.md"
  spec.metadata["bug_tracker_uri"] = "#{spec.homepage}/issues"

  spec.files         = Dir['lib/**/*', 'CHANGELOG.md', 'LICENSE.txt', 'README.md']
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 2.7.0"

  spec.add_development_dependency "actionpack", ">= 7.1", "< 9"
  spec.add_development_dependency "rake", "~> 13.1"
  spec.add_development_dependency "rspec", "~> 3.12"
end
