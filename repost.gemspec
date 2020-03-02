
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "repost/version"

Gem::Specification.new do |spec|
  spec.name          = "repost"
  spec.version       = Repost::VERSION
  spec.authors       = ["YaroslavO"]
  spec.email         = ["osyaroslav@gmail.com"]

  spec.summary       = %q{Gem implements Redirect using POST method}
  spec.description   = %q{Helps to make POST 'redirect', but actually builds [form] with method: :post under the hood}
  spec.homepage      = "https://vergilet.github.io/repost/"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)

    spec.metadata["homepage_uri"] = spec.homepage
    # spec.metadata["source_code_uri"] = "Put your gem's public repo URL here."
    # spec.metadata["changelog_uri"] = "Put your gem's CHANGELOG.md URL here."
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.rdoc']
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", ">= 12.3.3"
  spec.add_development_dependency "rspec", "~> 3.0"
end
