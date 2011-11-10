require 'ostruct'
module Cipr
  class PullRequest < OpenStruct
    def initialize(repo, *args)
      @repo = repo
      super(*args)
    end

    def comment(body)
      @repo.comment(self.number, body)
    end

    def mergeable?
      mergeable
    end

    def merged?
      merged
    end

    def username
      head['user']['login']
    end

    def merge_to
      base['ref']
    end

    def merge_from
      head['ref']
    end

    def pull_repo
      auth = @repo.auth_string
      if auth && !auth.empty?
        head['repo']['clone_url'].sub("https://", "https://#{auth}@")
      else
        head['repo']['clone_url']
      end
    end

    def apply
      @repo.apply_pull_request(self)
    end

    def checkout
      @repo.checkout_pull_request(self)
    end

  end
end