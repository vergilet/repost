module Repost
  class Action
    def self.perform(*args)
      action = new(*args)
      action.perform
    end
  end
end
