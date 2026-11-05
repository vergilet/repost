require "bundler/setup"

# Load Action Controller before repost, the same order as in a Rails app,
# so repost's controller helpers get installed.
require "action_controller"
require "repost"

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
