module Repost
  class Error < StandardError; end
  # Raised when the target URL uses a scheme that isn't allowed (javascript:, data:, ...).
  class UnsafeUrlError < Error; end
end

require "repost/version"
require "repost/action"
require "repost/senpai"
require "repost/extend_controller"
