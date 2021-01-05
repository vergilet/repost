module Repost
  class Action
    def self.perform(*args, **kw_args)
      action = new(*args, **kw_args)
      action.perform
    end
  end
end
